provider "azurerm" {}

terraform {
  backend "azurerm" {
    storage_account_name = "sbtktfstate"
    container_name = "tfstate"
    key = "snippets/azure/virtual_machines/scale_set/scale_set.tfstate"
  }
}

resource "azurerm_resource_group" "sample" {
  name = "sample"
  location = "Japan East"
}

# Network

resource "azurerm_virtual_network" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  virtual_network_name = "${azurerm_virtual_network.sample.name}"
  address_prefix = "10.0.2.0/24"
}

# LoadBalancer

resource "azurerm_public_ip" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"
  public_ip_address_allocation = "static"
  domain_name_label = "sample"
}

resource "azurerm_lb" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.sample.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  loadbalancer_id = "${azurerm_lb.sample.id}"
}

resource "azurerm_lb_nat_pool" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  loadbalancer_id = "${azurerm_lb.sample.id}"
  count = 3
  protocol = "Tcp"
  frontend_port_start = 50000
  frontend_port_end = 50119
  backend_port = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Scale set

resource "azurerm_virtual_machine_scale_set" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"
  upgrade_policy_mode = "Manual"

  sku {
    name = "Standard_DS1_v2"
    tier = "Standard"
    capacity = 1
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_profile_os_disk {
    name = ""
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_profile_data_disk {
    lun = 0
    caching = "ReadWrite"
    create_option = "Empty"
    disk_size_gb = 10
  }

  os_profile {
    computer_name_prefix = "sample"
    admin_username = "ubuntu"
    admin_password = "password"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/azure_default.pub")}"
    }
  }

  network_profile {
    name = "TestNetworkProfile"
    primary = true
    ip_configuration {
      name = "TestIPConfiguration"
      subnet_id = "${azurerm_subnet.sample.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.sample.id}"]
      load_balancer_inbound_nat_rules_ids = ["${element(azurerm_lb_nat_pool.sample.*.id, count.index)}"]
    }
  }
}

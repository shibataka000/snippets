provider "azurerm" {}

terraform {
  backend "azurerm" {
    storage_account_name = "sbtktfstate"
    container_name = "tfstate"
    key = "snippets/azure/virtual_machines/linux_virtual_machines/linux_virtual_machines.tfstate"
  }
}

resource "azurerm_resource_group" "sample" {
  name = "sample"
  location = "Japan East"
}

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

resource "azurerm_network_security_group" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_interface" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"

  ip_configuration {
    name = "sample"
    subnet_id = "${azurerm_subnet.sample.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.sample.id}"
  }
}

resource "azurerm_virtual_machine" "sample" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"
  network_interface_ids = ["${azurerm_network_interface.sample.id}"]

  vm_size = "Standard_DS1_v2"

  storage_os_disk {
    name = "sample"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  os_profile {
    computer_name = "sample"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/azure_default.pub")}"
    }
  }
}

output "ssh" {
  value = "ssh -i ~/.ssh/azure_default ubuntu@${azurerm_public_ip.sample.ip_address}"
}

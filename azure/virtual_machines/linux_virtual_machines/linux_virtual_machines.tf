provider "azurerm" {}

variable "location" {
  default = "Japan East"
}

terraform {
  backend "azurerm" {
    storage_account_name = "sbtktfstate"
    container_name = "tfstate"
    key = "snippets/azure/virtual_machines/linux_virtual_machines/linux_virtual_machines.tfstate"
  }
}

resource "azurerm_resource_group" "rg" {
  name = "sample"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name = "sample"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name = "sample"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "10.0.2.0/24"
}

resource "azurerm_public_ip" "public_ip" {
  name = "sample"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name = "sample"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

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

resource "azurerm_network_interface" "nic" {
  name = "sample"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name = "sample"
    subnet_id = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.public_ip.id}"
  }
}

resource "random_id" "random_id" {
  keepers = {
    resource_group = "${azurerm_resource_group.rg.name}"
  }
  byte_length = 8
}

resource "azurerm_storage_account" "sa" {
  name = "disk${random_id.random_id.hex}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  account_replication_type = "LRS"
  account_tier = "Standard"
}

resource "azurerm_virtual_machine" "vm" {
  name = "sample"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

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

  boot_diagnostics {
    enabled = "true"
    storage_uri = "${azurerm_storage_account.sa.primary_blob_endpoint}"
  }
}

output "ssh" {
  value = "ssh -i ~/.ssh/azure_default ubuntu@${azurerm_public_ip.public_ip.ip_address}"
}

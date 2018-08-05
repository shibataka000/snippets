provider "azurerm" {}

terraform {
  backend "azurerm" {
    storage_account_name = "sbtktfstate"
    container_name = "tfstate"
    key = "snippets/azure/storage/blob.tfstate"
  }
}

resource "azurerm_resource_group" "sample" {
  name = "storage-blob-sample"
  location = "Japan East"
}

resource "azurerm_storage_account" "sample" {
  name = "sbtksample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  location = "${azurerm_resource_group.sample.location}"
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sample" {
  name = "sbtksample"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  storage_account_name = "${azurerm_storage_account.sample.name}"
  container_access_type = "private"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "sbtktfstate"
    container_name       = "tfstate"
    key                  = "snippets/azure/aks/aks.tfstate"
  }
}

provider "azurerm" {
  features {}
}

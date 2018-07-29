provider "azurerm" {}

terraform {
  backend "azurerm" {
    storage_account_name = "sbtktfstate"
    container_name = "tfstate"
    key = "snippets/azure/app_service/app_service.tfstate"
  }
}

resource "azurerm_resource_group" "sample" {
  name = "app-service-sample"
  location = "Japan East"
}

resource "azurerm_app_service_plan" "sample" {
  name = "app-service-sample"
  location = "${azurerm_resource_group.sample.location}"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  kind = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }

  properties {
    reserved = true
  }
}

resource "azurerm_app_service" "sample" {
  name = "sbtkappservice"
  location = "${azurerm_resource_group.sample.location}"
  resource_group_name = "${azurerm_resource_group.sample.name}"
  app_service_plan_id = "${azurerm_app_service_plan.sample.id}"

  site_config {
    linux_fx_version = "DOCKER|shibataka000/flask-quickstart"
  }

  app_settings {
    WEBSITES_PORT = 8000
  }
}

output "url" {
  value = "https://${azurerm_app_service.sample.name}.azurewebsites.net"
}

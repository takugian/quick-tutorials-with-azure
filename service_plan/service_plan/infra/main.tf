provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_service_plan" "service_plan" {
  location                     = var.LOCATION
  resource_group_name          = azurerm_resource_group.resource_group.name
  name                         = "service-plan"
  os_type                      = "Linux"
  sku_name                     = "P1v2"
  worker_count                 = 2
  maximum_elastic_worker_count = 4
  per_site_scaling_enabled     = false
  zone_balancing_enabled       = false
  depends_on                   = [azurerm_resource_group.resource_group]
}

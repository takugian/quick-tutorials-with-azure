provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "log-analytics-workspace"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP
  sku                 = "Free"
  retention_in_days   = 7

  tags = {
    environment = "development"
  }
}

resource "azurerm_application_insights" "application_insights" {
  name                       = "application-insights"
  resource_group_name        = var.RESOURCE_GROUP
  location                   = var.LOCATION
  application_type           = "Node.JS"
  retention_in_days          = 90
  sampling_percentage        = 100
  disable_ip_masking         = false
  workspace_id               = azurerm_log_analytics_workspace.log_analytics_workspace.id
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  depends_on                 = [azurerm_resource_group.resource_group]

  tags = {
    environment = "development"
  }
}
provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  name               = "monitor-diagnostic-setting"
  target_resource_id = var.LINUX_WEB_APP_ID
  storage_account_id = var.STORAGE_ACCOUNT_ID

  enabled_log {
    category = "AppServiceAppLogs"

    retention_policy {
      enabled = true
      days    = 1
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 1
    }
  }
}

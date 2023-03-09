provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_monitor_action_group" "monitor_action_group" {
  resource_group_name = var.RESOURCE_GROUP
  name                = "monitor-action-group"
  short_name          = "mag"

  email_receiver {
    name          = "takugian"
    email_address = var.EMAIL_RECEIVER

  }
}

resource "azurerm_monitor_activity_log_alert" "monitor_activity_log_alert" {
  resource_group_name = var.RESOURCE_GROUP
  name                = "monitor-activity-log-alert"
  scopes              = [var.LINUX_WEB_APP_ID]
  description         = "This alert will monitor a specific storage account updates."

  criteria {
    resource_id    = var.LINUX_WEB_APP_ID
    operation_name = "Microsoft.Web/sites/Write"
    category       = "Recommendation"
  }

  action {
    action_group_id = azurerm_monitor_action_group.monitor_action_group.id
  }
}

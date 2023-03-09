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

resource "azurerm_monitor_metric_alert" "monitor_metric_alert" {
  resource_group_name = var.RESOURCE_GROUP
  name                = "monitor-metric-alert"
  scopes              = [var.LINUX_WEB_APP_ID]
  description         = "Action will be triggered when Maximum AverageMemoryWorkingSet is greater than 200."
  frequency           = "PT1M"
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageMemoryWorkingSet"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 200

    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.monitor_action_group.id
  }
}

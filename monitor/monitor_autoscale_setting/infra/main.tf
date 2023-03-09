provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_monitor_autoscale_setting" "monitor_autoscale_setting" {
  resource_group_name = var.RESOURCE_GROUP
  location            = var.LOCATION
  name                = "monitor-autoscale-setting"
  target_resource_id  = var.SERVICE_PLAN_ID

  profile {
    name = "default"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_namespace   = "microsoft.web/serverfarms"
        metric_resource_id = var.SERVICE_PLAN_ID
        operator           = "GreaterThan"
        statistic          = "Max"
        time_aggregation   = "Maximum"
        time_grain         = "PT1M"
        time_window        = "PT10M"
        threshold          = 50

        # dimensions {
        #   name     = "Instance"
        #   operator = "Equals"
        #   values   = ["*"]
        # }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_namespace   = "microsoft.web/serverfarms"
        metric_resource_id = var.SERVICE_PLAN_ID
        operator           = "GreaterThan"
        statistic          = "Max"
        time_aggregation   = "Maximum"
        time_grain         = "PT1M"
        time_window        = "PT10M"
        threshold          = 50

        dimensions {
          name     = "Instance"
          operator = "Equals"
          values   = ["*"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT5M"
      }
    }

    # recurrence {
    #   timezone = "Pacific Standard Time"
    #   days     = ["Saturday", "Sunday"]
    #   hours    = [12]
    #   minutes  = [0]
    # }

    # fixed_date {
    #   timezone = "Pacific Standard Time"
    #   start    = "2020-07-01T00:00:00Z"
    #   end      = "2020-07-31T23:59:59Z"
    # }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = [var.EMAIL_NOTIFICATION]
    }
  }
}

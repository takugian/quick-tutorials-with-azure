provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "random_string" "random" {
  length  = 6
  special = false
  lower   = true
  upper   = false
}

locals {
  use_case_name = "rest-nodejs-api-${random_string.random.result}"
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_service_plan" "service_plan" {
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${local.use_case_name}-sp"
  os_type             = "Linux"
  sku_name            = "P1v2"
  depends_on          = [azurerm_resource_group.resource_group]
}

resource "azurerm_application_insights" "application_insights" {
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP
  name                = "${local.use_case_name}-ai"
  application_type    = "Node.JS"
  depends_on          = [azurerm_resource_group.resource_group]
}

resource "azurerm_linux_web_app" "linux_web_app" {
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${local.use_case_name}-lwa"
  service_plan_id     = azurerm_service_plan.service_plan.id
  depends_on          = [azurerm_resource_group.resource_group]

  site_config {
    health_check_path                 = "/"
    health_check_eviction_time_in_min = 2

    application_stack {
      node_version = "18-lts"
    }

    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY             = azurerm_application_insights.application_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.application_insights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES        = 10
    WEBSITES_ENABLE_APP_SERVICE_STORAGE        = false
    XDT_MicrosoftApplicationInsights_Mode      = "recommended"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 100
      }
    }
  }

  tags = {
    environment = "development"
  }
}

resource "azurerm_app_service_source_control" "app_service_source_control" {
  app_id   = azurerm_linux_web_app.linux_web_app.id
  repo_url = "https://github.com/takugian/rest_nodejs_api"
  branch   = "mock"

  github_action_configuration {
    generate_workflow_file = true

    code_configuration {
      runtime_stack   = "node"
      runtime_version = "18.x"
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "monitor_autoscale_setting" {
  resource_group_name = var.RESOURCE_GROUP
  location            = var.LOCATION
  name                = "${local.use_case_name}-mas"
  target_resource_id  = azurerm_service_plan.service_plan.id

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
        metric_resource_id = azurerm_service_plan.service_plan.id
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
        metric_resource_id = azurerm_service_plan.service_plan.id
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
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = [var.EMAIL_NOTIFICATION]
    }
  }
}

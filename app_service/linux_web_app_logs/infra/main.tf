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

resource "azurerm_storage_account" "storage_account" {
  location                 = var.LOCATION
  resource_group_name      = azurerm_resource_group.resource_group.name
  name                     = "qtsa${random_string.random.result}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_resource_group.resource_group]
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "${local.use_case_name}-sc"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_resource_group.resource_group]
}

data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name
  https_only        = false
  # ip_address          = "168.1.5.65"
  start  = "2023-01-01"
  expiry = "2023-12-31"
  # cache_control       = "max-age=5"
  # content_disposition = "inline"
  # content_encoding    = "deflate"
  # content_language    = "en-US"
  # content_type        = "application/json"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

resource "azurerm_service_plan" "service_plan" {
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${local.use_case_name}-sp"
  os_type             = "Linux"
  sku_name            = "B1"
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
      azure_blob_storage {
        level             = "Verbose"
        retention_in_days = 1
        sas_url           = data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas
      }
    }

    http_logs {
      # file_system {
      #   retention_in_days = 1
      #   retention_in_mb   = 100
      # }
      azure_blob_storage {
        retention_in_days = 1
        sas_url           = data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas
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

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  name               = "${local.use_case_name}-mds"
  target_resource_id = azurerm_linux_web_app.linux_web_app.id
  storage_account_id = azurerm_storage_account.storage_account.id

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

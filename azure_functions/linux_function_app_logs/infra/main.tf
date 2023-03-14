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
  use_case_name = "nodejs-azure-function-app-${random_string.random.result}"
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

resource "azurerm_storage_account" "storage_account" {
  location                 = var.LOCATION
  resource_group_name      = var.RESOURCE_GROUP
  name                     = "storageaccount${random_string.random.result}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_resource_group.resource_group]
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "storagecontainer${random_string.random.result}"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_resource_group.resource_group]
}

# data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
#   connection_string = azurerm_storage_account.storage_account.primary_connection_string
#   container_name    = azurerm_storage_container.storage_container.name
#   https_only        = false
#   # ip_address          = "168.1.5.65"
#   start  = "2023-01-01"
#   expiry = "2023-12-31"
#   # cache_control       = "max-age=5"
#   # content_disposition = "inline"
#   # content_encoding    = "deflate"
#   # content_language    = "en-US"
#   # content_type        = "application/json"

#   permissions {
#     read   = true
#     add    = true
#     create = true
#     write  = true
#     delete = true
#     list   = true
#   }
# }

resource "azurerm_linux_function_app" "linux_function_app" {
  location                   = var.LOCATION
  resource_group_name        = azurerm_resource_group.resource_group.name
  name                       = "${local.use_case_name}-lfa"
  service_plan_id            = azurerm_service_plan.service_plan.id
  enabled                    = true
  https_only                 = false
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  depends_on                 = [azurerm_resource_group.resource_group]

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insights.instrumentation_key
    AzureWebJobsSecretStorageType  = "files"
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
  }

  site_config {
    app_scale_limit                        = 2
    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
    health_check_path                      = "/"
    health_check_eviction_time_in_min      = 2

    application_stack {
      node_version = 18
    }

    app_service_logs {
      disk_quota_mb         = 35
      retention_period_days = 1
    }

    cors {
      allowed_origins = ["*"]
    }

  }
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  name               = "${local.use_case_name}-mds"
  target_resource_id = azurerm_linux_function_app.linux_function_app.id
  storage_account_id = azurerm_storage_account.storage_account.id

  enabled_log {
    category = "FunctionAppLogs"

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

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

resource "azurerm_linux_function_app" "linux_function_app" {
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${local.use_case_name}-lfa"
  service_plan_id     = azurerm_service_plan.service_plan.id
  enabled             = true
  https_only          = false
  depends_on          = [azurerm_resource_group.resource_group]
  #   storage_account_name       = azurerm_storage_account.storage_account.name
  #   storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  #   storage_key_vault_secret_id     = ""
  #   key_vault_reference_identity_id = ""
  # virtual_network_subnet_id     = ""

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    # AzureWebJobsStorage            = azurerm_storage_account.storage_account.primary_blob_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insights.instrumentation_key
    WEBSITE_RUN_FROM_PACKAGE       = "1"
  }

  site_config {

    app_scale_limit                        = 2
    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
    health_check_path                      = "/"
    health_check_eviction_time_in_min      = 2
    load_balancing_mode                    = "LeastRequests"
    worker_count                           = 1

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

  # connection_string {}

  # auth_settings {}

  # identity {}

  # backup {}

  # sticky_settings {}

  tags = {
    environment = "development"
  }

}
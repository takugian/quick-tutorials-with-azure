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
  use_case_name              = "nodejs-api-${random_string.random.result}"
  docker_registry_server_url = "https://${var.DOCKER_REGISTRY_SERVER_USERNAME}.azurecr.io"
  docker_image               = "${var.DOCKER_REGISTRY_SERVER_USERNAME}.azurecr.io/rest_api_nodejs"
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

resource "azurerm_linux_web_app" "linux_web_app" {
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  name                = "${local.use_case_name}-lwa"
  service_plan_id     = azurerm_service_plan.service_plan.id
  https_only          = false
  enabled             = true
  depends_on          = [azurerm_resource_group.resource_group]

  site_config {
    always_on = true
    # app_command_line
    health_check_path                 = "/"
    health_check_eviction_time_in_min = 2
    # ip_restriction 
    load_balancing_mode = "LeastRequests"
    local_mysql_enabled = false
    worker_count        = 2

    application_stack {
      docker_image     = local.docker_image
      docker_image_tag = "latest"
    }

    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY             = azurerm_application_insights.application_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.application_insights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    DOCKER_REGISTRY_SERVER_URL                 = local.docker_registry_server_url
    DOCKER_REGISTRY_SERVER_USERNAME            = var.DOCKER_REGISTRY_SERVER_USERNAME
    DOCKER_REGISTRY_SERVER_PASSWORD            = var.DOCKER_REGISTRY_SERVER_PASSWORD
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES        = 10
    WEBSITES_ENABLE_APP_SERVICE_STORAGE        = false
    WEBSITES_PORT                              = 3070
    XDT_MicrosoftApplicationInsights_Mode      = "recommended"
  }

  # connection_string {}

  tags = {
    environment = "development"
  }
}

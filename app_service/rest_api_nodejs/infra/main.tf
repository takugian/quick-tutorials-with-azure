provider "azurerm" {
    subscription_id = var.SUBSCRIPTION_ID
    tenant_id = var.TENANT_ID
    features { }
}

resource "azurerm_resource_group" "resource_group" {
    name        = var.RESOURCE_GROUP
    location    = var.LOCATION  
}

resource "random_string" "random" {
  length  = 6
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_storage_account" "storage_account" {
    name                        = "qtsa${random_string.random.result}"
    location                    = var.LOCATION
    resource_group_name         = azurerm_resource_group.resource_group.name    
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    depends_on                  = [azurerm_resource_group.resource_group]

    logg
}

resource "azurerm_storage_container" "storage_container" {
    name                        = "app-service-rest-api-nodejs"
    storage_account_name        = azurerm_storage_account.storage_account.name
    container_access_type       = "blob"
    depends_on                  = [azurerm_resource_group.resource_group]
}

resource "azurerm_service_plan" "service_plan" {
    name                    = "app-service-rest-api-nodejs"
    location                = var.LOCATION
    resource_group_name     = azurerm_resource_group.resource_group.name
    os_type                 = "Linux"
    sku_name                = "B1"
}

resource "azurerm_application_insights" "application_insights" {
    name                    = "app-service-rest-api-nodejs"
    location                = var.LOCATION
    resource_group_name     = var.RESOURCE_GROUP
    application_type        = "Node.JS"
}

resource "azurerm_linux_web_app" "linux_web_app" {
    name                                 = "app-service-rest-api-nodejs"
    location                            = var.LOCATION
    resource_group_name                 = azurerm_resource_group.resource_group.name
    service_plan_id                     = azurerm_service_plan.service_plan.id
    https_only                          = false
    # key_vault_reference_identity_id     =
    # virtual_network_subnet_id           =

    app_settings = {
        AzureWebJobsStorage                             = azurerm_storage_account.storage_account.primary_blob_connection_string
        APPINSIGHTS_INSTRUMENTATIONKEY                  = azurerm_application_insights.application_insights.instrumentation_key
        APPLICATIONINSIGHTS_CONNECTION_STRING           = azurerm_application_insights.application_insights.connection_string
        APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
        APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
        ApplicationInsightsAgent_EXTENSION_VERSION      = "~3"
        DiagnosticServices_EXTENSION_VERSION            = "~3"
        InstrumentationEngine_EXTENSION_VERSION         = "disabled"
        SnapshotDebugger_EXTENSION_VERSION              = "disabled"
        WEBSITE_HEALTHCHECK_MAXPINGFAILURES             = 2
        XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
        XDT_MicrosoftApplicationInsights_Mode           = "recommended"
        XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
        WEBSITES_PORT                                   = 3070
        DOCKER_REGISTRY_SERVER_URL                      = var.DOCKER_REGISTRY_SERVER_URL
        DOCKER_REGISTRY_SERVER_USERNAME                 = var.DOCKER_REGISTRY_SERVER_USERNAME
        DOCKER_REGISTRY_SERVER_PASSWORD                 = var.DOCKER_REGISTRY_SERVER_PASSWORD
    }

    identity {
        type        = "SystemAssigned"
    }

    site_config {
        health_check_path                       = "/"
        health_check_eviction_time_in_min       = 2
        load_balancing_mode                     = "LeastRequests"
        worker_count                            = 2
        # always_on                               = false

        application_stack {
            docker_image            = "qtrestapinodejs.azurecr.io/rest_api_nodejs"
            docker_image_tag        = "latest"
        }

        cors {
            allowed_origins = ["*"]
        }
    }

    logs {
        detailed_error_messages     = true
        failed_request_tracing      = true

        application_logs {
            file_system_level     = "Verbose"
            azure_blob_storage {
                level                   = "Verbose"
                retention_in_days       = 1
                sas_url                 = azurerm_storage_account.storage_account.primary_blob_connection_string
            }
        }
    }

     # auth_settings {}

    # storage_account {}

    tags = {
        environment     = "development"
    }
}
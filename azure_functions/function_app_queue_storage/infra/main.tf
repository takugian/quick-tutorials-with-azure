provider "azurerm" {
    subscription_id = var.SUBSCRIPTION_ID
    tenant_id = var.TENANT_ID
    features { }
}

resource "azurerm_resource_group" "resource_group" {
    name        = var.RESOURCE_GROUP
    location    = var.LOCATION  
}

resource "azurerm_storage_account" "storage_account" {
    name                        = "qtazurefunctions123"
    location                    = var.LOCATION
    resource_group_name         = azurerm_resource_group.resource_group.name    
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    depends_on                  = [azurerm_resource_group.resource_group]
}

resource "azurerm_storage_container" "storage_container" {
    name                        = "function-app-queue-storage-storage-container"
    storage_account_name        = azurerm_storage_account.storage_account.name
    container_access_type       = "private"
    depends_on                  = [azurerm_resource_group.resource_group]
}

resource "azurerm_storage_queue" "storage_queue" {
    name                        = "js-queue-items"
    storage_account_name        = azurerm_storage_account.storage_account.name
}

resource "azurerm_service_plan" "service_plan" {
    name                            = "function-app-queue-storage-service-plan"
    location                        = var.LOCATION
    resource_group_name             = azurerm_resource_group.resource_group.name
    os_type                         = "Linux"
    sku_name                        = "B1"
    depends_on                      = [azurerm_resource_group.resource_group]

    tags = {
        environment     = "development"
    }
    
}

resource "azurerm_application_insights" "application_insights" {
    name                    = "function-app-queue-storage-application-insights"
    location                = var.LOCATION
    resource_group_name     = var.RESOURCE_GROUP
    application_type        = "Node.JS"
}

resource "azurerm_linux_function_app" "linux_function_app" {
    name                            = "function-app-my-function"
    location                        = var.LOCATION
    resource_group_name             = azurerm_resource_group.resource_group.name
    storage_account_name            = azurerm_storage_account.storage_account.name
    storage_account_access_key      = azurerm_storage_account.storage_account.primary_access_key
    service_plan_id                 = azurerm_service_plan.service_plan.id
    depends_on                       = [azurerm_resource_group.resource_group]

    app_settings = {
        FUNCTIONS_WORKER_RUNTIME            = "node"
        AzureWebJobsStorage                 = azurerm_storage_account.storage_account.primary_blob_connection_string
        APPINSIGHTS_INSTRUMENTATIONKEY      = azurerm_application_insights.application_insights.instrumentation_key
        WEBSITE_RUN_FROM_PACKAGE            = "1"
    }

    site_config {

        application_stack {
            node_version                = 18
        }

        cors {
            allowed_origins             = ["*"]
        }

    }

    tags = {
        environment     = "development"
    }

}
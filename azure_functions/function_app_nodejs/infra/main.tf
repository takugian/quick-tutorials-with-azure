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
    name                        = "function-app-nodejs-storage-container"
    storage_account_name        = azurerm_storage_account.storage_account.name
    container_access_type       = "private"
    depends_on                  = [azurerm_resource_group.resource_group]
}

resource "azurerm_service_plan" "service_plan" {
    name                            = "function-app-nodejs-service-plan"
    location                        = var.LOCATION
    resource_group_name             = azurerm_resource_group.resource_group.name
    os_type                         = "Linux"
    sku_name                        = "B1"
    # app_service_environment_id      =
    # maximum_elastic_worker_count    =
    # worker_count                    =
    # per_site_scaling_enabled        =
    # zone_balancing_enabled          =
    depends_on                      = [azurerm_resource_group.resource_group]

    tags = {
        environment     = "development"
    }
    
}

# resource "azurerm_application_insights" "application_insights" {
#     name                    = "func-application-insights"
#     location                = var.LOCATION
#     resource_group_name     = var.RESOURCE_GROUP
#     application_type        = "Node.JS"
# }

resource "azurerm_linux_function_app" "linux_function_app" {
    name                            = "function-app-my-function"
    location                        = var.LOCATION
    resource_group_name             = azurerm_resource_group.resource_group.name
    storage_account_name            = azurerm_storage_account.storage_account.name
    storage_account_access_key      = azurerm_storage_account.storage_account.primary_access_key
    service_plan_id                 = azurerm_service_plan.service_plan.id
    # builtin_logging_enabled       = 
    # daily_memory_time_quota       = 
    enabled                         = true
    https_only                      = false
    # Assigning the virtual_network_subnet_id property requires RBAC permissions on the subnet
    # virtual_network_subnet_id     = 
    depends_on                       = [azurerm_resource_group.resource_group]

    app_settings = {
        FUNCTIONS_WORKER_RUNTIME            = "node"
        AzureWebJobsStorage                 = azurerm_storage_account.storage_account.primary_blob_connection_string
        # APPINSIGHTS_INSTRUMENTATIONKEY      = 
        WEBSITE_RUN_FROM_PACKAGE            = "1"
    }

    # auth_settings {
      
    # }

    # backup {
        # name                      =
        # storage_account_url       =
        # enabled                   = true

        # schedule {
        #     frequency_interval            =
        #     frequency_unit                =
        #     keep_at_least_one_backup      =
        #     retention_period_days         =
        #     start_time                    =
        # }

    # }

    site_config {

        # app_scale_limit                               = 
        # application_insights_connection_string        =
        # application_insights_key                      =
        # health_check_path                             = 
        # health_check_eviction_time_in_min             =
        # load_balancing_mode                           =
        # worker_count                                  =

        # app_service_logs {
        #     disk_quota_mb             =
        #     retention_period_days     =
        # }

        application_stack {
            node_version                = 18
        }

        cors {
            allowed_origins             = ["*"]
        }

    }

    # sticky_settings {
    #     app_setting_names             =
    #     connection_string_names       =
    # }

    tags = {
        environment     = "development"
    }

}
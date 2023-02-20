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
}

resource "azurerm_storage_container" "storage_container" {
    name                        = "service-bus-queue-storage-container"
    storage_account_name        = azurerm_storage_account.storage_account.name
    container_access_type       = "private"
    depends_on                  = [azurerm_resource_group.resource_group]
}

resource "azurerm_service_plan" "service_plan" {
    name                            = "service-bus-queue-service-plan"
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
    name                    = "service-bus-queue-application-insights"
    location                = var.LOCATION
    resource_group_name     = var.RESOURCE_GROUP
    application_type        = "Node.JS"
    depends_on              = [azurerm_resource_group.resource_group]
}

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
    name                                = "service-bus-queue-namespace"
    location                            = var.LOCATION
    resource_group_name                 = var.RESOURCE_GROUP
    sku                                 = "Standard"
    capacity                            = 0
    zone_redundant                      = false
    public_network_access_enabled       = true
    depends_on                          = [azurerm_resource_group.resource_group]

    # customer_managed_key {
    #     key_vault_key_id        =
    #     identity_id             =
    # }

    tags = {
        environment     = "development"
    }
}

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus_namespace_authorization_rule" {
    name                = "service-bus-queue-namespace-authz-rule"
    namespace_id        = azurerm_servicebus_namespace.servicebus_namespace.id
    listen              = true
    send                = true
    manage              = false
}

# resource "azurerm_servicebus_namespace_network_rule_set" "servicebus_namespace_network_rule_set" {
#     namespace_id                        = azurerm_servicebus_namespace.servicebus_namespace.id
#     default_action                      = "Deny"
#     public_network_access_enabled       = true
#     ip_rules                            = ["1.1.1.1"]

#     network_rules {
#         subnet_id                                   = var.VIRTUAL_NETWORK_SUBNET_ID_1
#         ignore_missing_vnet_service_endpoint        = false
#     }  
# }

resource "azurerm_servicebus_queue" "servicebus_queue" {
    name                                        = "service-bus-queue-queue"
    namespace_id                                = azurerm_servicebus_namespace.servicebus_namespace.id
    # lock_duration                               = "PT1M"
    # max_message_size_in_kilobytes               = 1024
    # requires_duplicate_detection                = false
    # requires_session                            = false
    # dead_lettering_on_message_expiration        = false    
    # max_delivery_count                          = 10
    # enable_partitioning                         = false
    # enable_express                              = false 
    # forward_to                                  = 
    # forward_dead_lettered_messages_to           =
    # status                                      = "Active"
}

resource "azurerm_servicebus_queue_authorization_rule" "servicebus_queue_authorization_rule" {
    name            = "service-bus-queue-queue-authz-rule"
    queue_id        = azurerm_servicebus_queue.servicebus_queue.id
    listen          = true
    send            = true
    manage          = false
}

resource "azurerm_linux_function_app" "linux_function_app" {
    name                            = "my-function-${random_string.random.result}"
    location                        = var.LOCATION
    resource_group_name             = azurerm_resource_group.resource_group.name
    storage_account_name            = azurerm_storage_account.storage_account.name
    storage_account_access_key      = azurerm_storage_account.storage_account.primary_access_key
    service_plan_id                 = azurerm_service_plan.service_plan.id
    depends_on                      = [azurerm_resource_group.resource_group]

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
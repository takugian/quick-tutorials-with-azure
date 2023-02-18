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
    name                                    = "qtstorageaccount123"
    location                                = var.LOCATION
    resource_group_name                     = azurerm_resource_group.resource_group.name
    account_kind                            = "StorageV2"
    account_tier                            = "Standard"
    access_tier                             = "Hot"
    account_replication_type                = "LRS"
    cross_tenant_replication_enabled        = true
    enable_https_traffic_only               = true
    # public_network_access_enabled           =

    # customer_managed_key {
    #     key_vault_key_id                =
    #     user_assigned_identity_id       =
    # }

    # network_rules {
    #     default_action                  = "Deny"
    #     bypass                          =
    #     ip_rules                        = ["100.0.0.1"]
    #     virtual_network_subnet_ids      = [var.VIRTUAL_NETWORK_SUBNET_ID_1]
    #     private_link_access {
    #         endpoint_resource_id        =
    #     }
    # }

    # static_website {
    #     index_document          =
    #     error_404_document      =
    # }

    # blob_properties {

    #     versioning_enabled      = 
        
    #     cors_rule {
          
    #     }

    #     delete_retention_policy {
          
    #     }
    # }

    # queue_properties {

    #     cors_rule {
          
    #     }

    #     logging {
    #         delete                      = 
    #         read                        = 
    #         version                     = 
    #         write                       = 
    #         retention_policy_days       = 
    #     }
    # }
    
    depends_on                  = [azurerm_resource_group.resource_group]
}

resource "azurerm_storage_container" "storage_container" {
    name                        = "qtcontainer123"
    storage_account_name        = azurerm_storage_account.storage_account.name
    container_access_type       = "private"
}

# resource "azurerm_storage_blob" "storage_blob" {
#     name                        = "qtblob.zip"
#     storage_account_name        = azurerm_storage_account.storage_account.name
#     storage_container_name      = azurerm_storage_container.storage_container.name
#     type                        = "Block"
#     source                      = "some-local-file.zip"
# }

resource "azurerm_storage_queue" "storage_queue" {
    name                        = "qtqueue123"
    storage_account_name        = azurerm_storage_account.storage_account.name
}

# resource "azurerm_storage_table" "storage_table" {
#     name                        = "qttable123"
#     storage_account_name        = azurerm_storage_account.storage_account.name
# }

# resource "azurerm_storage_table_entity" "storage_table_entity" {
#     storage_account_name        = azurerm_storage_account.storage_account.name
#     table_name                  = azurerm_storage_table.storage_table.name
#     partition_key               = "pk"
#     row_key                     = "rk"
    
#     entity = {
#         item = "item"
#     }
# }

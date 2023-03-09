provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "random_string" "random" {
  length  = 6
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_storage_account" "storage_account" {
  location                          = var.LOCATION
  resource_group_name               = azurerm_resource_group.resource_group.name
  name                              = "storageaccount${random_string.random.result}"
  account_kind                      = "StorageV2"
  account_tier                      = "Standard"
  access_tier                       = "Hot"
  account_replication_type          = "LRS"
  cross_tenant_replication_enabled  = true
  enable_https_traffic_only         = true
  public_network_access_enabled     = true
  queue_encryption_key_type         = "Service"
  table_encryption_key_type         = "Service"
  infrastructure_encryption_enabled = false
  depends_on                        = [azurerm_resource_group.resource_group]

  #   custom_domain {}

  #   customer_managed_key {}

  #   identity {}

  #   blob_properties {}

  #   queue_properties {}

  #   static_website {}

  # network_rules {
  #     default_action                  = "Deny"
  #     bypass                          = "Logging" // Logging, Metrics, AzureServices, or None
  #     ip_rules                        = [""]
  #     virtual_network_subnet_ids      = [var.VIRTUAL_NETWORK_SUBNET_ID_1]
  #     private_link_access {}
  # }
}

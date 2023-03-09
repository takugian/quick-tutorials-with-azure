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
  location                  = var.LOCATION
  resource_group_name       = azurerm_resource_group.resource_group.name
  name                      = "storageaccount${random_string.random.result}"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  access_tier               = "Hot"
  account_replication_type  = "LRS"
#   queue_encryption_key_type = ""
  depends_on                = [azurerm_resource_group.resource_group]

  # network_rules {}

  #   queue_properties {}
}

resource "azurerm_storage_queue" "storage_queue" {
  name                 = "storagequeue${random_string.random.result}"
  storage_account_name = azurerm_storage_account.storage_account.name
}

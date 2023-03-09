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
  location                 = var.LOCATION
  resource_group_name      = azurerm_resource_group.resource_group.name
  name                     = "storageaccount${random_string.random.result}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  access_tier              = "Hot"
  account_replication_type = "LRS"
  #   table_encryption_key_type = ""
  depends_on = [azurerm_resource_group.resource_group]

  # network_rules {}

}

resource "azurerm_storage_table" "storage_table" {
  name                 = "storagetable${random_string.random.result}"
  storage_account_name = azurerm_storage_account.storage_account.name
}

resource "azurerm_storage_table_entity" "storage_table_entity" {
  storage_account_name = azurerm_storage_account.storage_account.name
  table_name           = azurerm_storage_table.storage_table.name
  partition_key        = "pk"
  row_key              = "rk"

  entity = {
    item = "item"
  }
}

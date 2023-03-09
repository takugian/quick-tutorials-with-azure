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
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  access_tier              = "Hot"
  account_replication_type = "LRS"
  depends_on               = [azurerm_resource_group.resource_group]

  # network_rules {}

  blob_properties {
    versioning_enabled = false

    # cors_rule {}

    # delete_retention_policy {}

    # restore_policy {}
  }
}

resource "azurerm_storage_container" "storage_container" {
  storage_account_name  = azurerm_storage_account.storage_account.name
  name                  = "container${random_string.random.result}"
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "storage_blob" {
  name                   = "blob${random_string.random.result}"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"
  access_tier            = "Hot"
  # cache_control = "" 
  # content_type = ""
}

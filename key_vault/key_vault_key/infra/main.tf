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

data "azurerm_key_vault" "key_vault" {
  name                = var.KEY_VAULT_NAME
  resource_group_name = var.KEY_VAULT_RESOURCE_GROUP_NAME
}

resource "azurerm_key_vault_key" "key_vault_key" {
  name         = "keyvaultkey${random_string.random.result}"
  key_vault_id = data.azurerm_key_vault.key_vault.id
  key_type     = "RSA" // EC, EC-HSM, RSA and RSA-HSM
  key_size     = 2048
  # not_before_date = "" // Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z')
  # expiration_date = "" // Expiration UTC datetime (Y-m-d'T'H:M:S'Z')

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    expire_after         = "P90D"
    notify_before_expiry = "P29D"

    automatic {
      time_before_expiry = "P30D"
    }
  }

  tags = {
    "environment" = "development"
  }
}

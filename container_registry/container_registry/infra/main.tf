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

# data "azurerm_key_vault" "key_vault" {
#   name = var.KEY_VAULT_NAME
# }

# data "azurerm_key_vault_key" "key_vault_key" {
#   name         = var.KEY_VAULT_KEY_NAME
#   key_vault_id = data.azurerm_key_vault.key_vault.id
# }

# resource "azurerm_user_assigned_identity" "user_assigned_identity" {
#   location            = var.LOCATION
#   name                = "userassignedidentity${random_string.random.result}"
#   resource_group_name = var.RESOURCE_GROUP
# }

resource "azurerm_container_registry" "container_registry" {
  name                          = "containerregistry${random_string.random.result}"
  resource_group_name           = var.RESOURCE_GROUP
  location                      = var.LOCATION
  sku                           = "Basic"
  admin_enabled                 = true
  public_network_access_enabled = true
  zone_redundancy_enabled       = false
  network_rule_bypass_option    = "AzureServices"

  #   network_rule_set = [{
  #     default_action = ""
  #     ip_rule = [{
  #       action   = ""
  #       ip_range = ""
  #     }]
  #     virtual_network = [{
  #       action    = ""
  #       subnet_id = ""
  #     }]
  #   }]

  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     azurerm_user_assigned_identity.user_assigned_identity.id
  #   ]
  # }

  # encryption {
  #   key_vault_key_id   = data.azurerm_key_vault_key.key_vault_key.id
  #   identity_client_id = azurerm_user_assigned_identity.user_assigned_identity.client_id
  #   enabled            = true
  # }

  #   georeplications {
  #     location                = "East US"
  #     zone_redundancy_enabled = true
  #     tags                    = {}
  #   }

  tags = {
    "environment" = "development"
  }
}

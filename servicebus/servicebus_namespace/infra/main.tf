provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "random_string" "random" {
  length  = 6
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  location                      = var.LOCATION
  resource_group_name           = var.RESOURCE_GROUP
  name                          = "servicebus-namespace-${random_string.random.result}"
  sku                           = "Standard"
  capacity                      = 0
  local_auth_enabled            = true
  public_network_access_enabled = true
  zone_redundant                = false
  depends_on                    = [azurerm_resource_group.resource_group]

  # identity {}

  # customer_managed_key {}
}

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus_namespace_authorization_rule" {
  name         = "servicebus-namespace-authorization-rule"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
  listen       = true
  send         = true
  manage       = false
}

# resource "azurerm_servicebus_namespace_network_rule_set" "servicebus_namespace_network_rule_set" {
#   namespace_id                  = azurerm_servicebus_namespace.servicebus_namespace.id
#   default_action                = "Deny"
#   public_network_access_enabled = true
#   ip_rules                      = var.IPS_TO_ACCESS_NAMESPACE

#   network_rules {
#     subnet_id                            = var.SUBNET_ID
#     ignore_missing_vnet_service_endpoint = false
#   }
# }

# resource "azurerm_servicebus_namespace_disaster_recovery_config" "servicebus_namespace_disaster_recovery_config" {
#   name                        = "servicebus-namespace-disaster-recovery-config"
#   primary_namespace_id        = azurerm_servicebus_namespace.servicebus_namespace_primary.id
#   partner_namespace_id        = azurerm_servicebus_namespace.servicebus_namespace_secondary.id
#   alias_authorization_rule_id = azurerm_servicebus_namespace_authorization_rule.servicebus_namespace_authorization_rule.id
# }
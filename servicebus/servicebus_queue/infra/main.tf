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
  public_network_access_enabled = true
  depends_on                    = [azurerm_resource_group.resource_group]
}

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus_namespace_authorization_rule" {
  name         = "namespace-authorization-rule"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
  listen       = true
  send         = true
  manage       = false
}

resource "azurerm_servicebus_queue" "servicebus_queue_forward" {
  name         = "queue-forward-${random_string.random.result}"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
}

resource "azurerm_servicebus_queue" "servicebus_queue_dlq" {
  name         = "queue-dlq-${random_string.random.result}"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
}

resource "azurerm_servicebus_queue" "servicebus_queue" {
  name                                    = "servicebus-queue-${random_string.random.result}"
  namespace_id                            = azurerm_servicebus_namespace.servicebus_namespace.id
  forward_to                              = azurerm_servicebus_queue.servicebus_queue_forward.name
  forward_dead_lettered_messages_to       = azurerm_servicebus_queue.servicebus_queue_dlq.name
  lock_duration                           = "PT1M"
  max_size_in_megabytes                   = 1024
  requires_duplicate_detection            = false
  requires_session                        = false
  default_message_ttl                     = "PT10M"
  dead_lettering_on_message_expiration    = false
  duplicate_detection_history_time_window = "PT10M"
  max_delivery_count                      = 10
  enable_batched_operations               = false
  auto_delete_on_idle                     = "PT10M"
  enable_partitioning                     = false
  enable_express                          = false
}

resource "azurerm_servicebus_queue_authorization_rule" "servicebus_queue_authorization_rule" {
  name     = "queue-authorization-rule"
  queue_id = azurerm_servicebus_queue.servicebus_queue.id
  listen   = true
  send     = true
  manage   = false
}

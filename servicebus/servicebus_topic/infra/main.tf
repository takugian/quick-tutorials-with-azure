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
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP
  name                = "servicebus-namespace-${random_string.random.result}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus_namespace_authorization_rule" {
  name         = "namespace-authorization-rule"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
  listen       = true
  send         = true
  manage       = false
}

resource "azurerm_servicebus_topic" "servicebus_topic_forward" {
  name         = "topic-forward-${random_string.random.result}"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
}

resource "azurerm_servicebus_topic" "servicebus_topic_dlq" {
  name         = "topic-dlq-${random_string.random.result}"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
}

resource "azurerm_servicebus_topic" "servicebus_topic" {
  name                                    = "topic-${random_string.random.result}"
  namespace_id                            = azurerm_servicebus_namespace.servicebus_namespace.id
  auto_delete_on_idle                     = "PT10M"
  default_message_ttl                     = "PT10M"
  duplicate_detection_history_time_window = "PT10M"
  enable_batched_operations               = false
  enable_express                          = false
  enable_partitioning                     = false
  max_size_in_megabytes                   = 1024
  requires_duplicate_detection            = false
  support_ordering                        = false
}

resource "azurerm_servicebus_topic_authorization_rule" "servicebus_topic_authorization_rule" {
  name     = "topic-authorization-rule"
  topic_id = azurerm_servicebus_topic.servicebus_topic.id
  listen   = true
  send     = false
  manage   = false
}

resource "azurerm_servicebus_subscription" "servicebus_subscription" {
  name                                      = "subscription"
  topic_id                                  = azurerm_servicebus_topic.servicebus_topic.id
  max_delivery_count                        = 1
  auto_delete_on_idle                       = "PT5M"
  default_message_ttl                       = ""
  lock_duration                             = "P0DT0H5M0S"
  dead_lettering_on_message_expiration      = false
  dead_lettering_on_filter_evaluation_error = true
  enable_batched_operations                 = false
  requires_session                          = false
  forward_to                                = azurerm_servicebus_topic.servicebus_topic_forward.name
  forward_dead_lettered_messages_to         = azurerm_servicebus_topic.servicebus_topic_dlq.name
  status                                    = "Active"

  # client_scoped_subscription {}
}

resource "azurerm_servicebus_subscription_rule" "servicebus_subscription_rule" {
  name            = "subscription-rule"
  subscription_id = azurerm_servicebus_subscription.servicebus_subscription.id
  filter_type     = "SqlFilter"
  sql_filter      = "colour = 'red'"
}

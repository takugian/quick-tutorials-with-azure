provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_storage_account" "storage_account" {
  location                 = azurerm_resource_group.resource_group.location
  resource_group_name      = azurerm_resource_group.resource_group.name
  name                     = "storageaccount1a2b3c"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "storage_queue" {
  name                 = "queue"
  storage_account_name = azurerm_storage_account.storage_account.name
}

resource "azurerm_eventgrid_topic" "eventgrid_topic" {
  location                      = azurerm_resource_group.resource_group.location
  resource_group_name           = azurerm_resource_group.resource_group.name
  name                          = "topic"
  public_network_access_enabled = true

  # identity {}

  # input_mapping_fields {
  #   id           = ""
  #   topic        = ""
  #   event_time   = ""
  #   event_type   = ""
  #   data_version = ""
  #   subject      = ""
  # }

  # input_mapping_default_values {
  #   event_type   = ""
  #   data_version = ""
  #   subject      = ""
  # }

  # inbound_ip_rule = []
}

resource "azurerm_eventgrid_event_subscription" "eventgrid_event_subscription" {
  name                                 = "event-subscription"
  scope                                = azurerm_eventgrid_topic.eventgrid_topic.id
  expiration_time_utc                  = "2024-01-01T00:00:00.00Z"
  event_delivery_schema                = "EventGridSchema"
  included_event_types                 = ["QuickTutorialsWithAzure.EventGrid.UseCaseCreated"]
  advanced_filtering_on_arrays_enabled = false

  retry_policy {
    max_delivery_attempts = 10
    event_time_to_live    = 10
  }

  storage_queue_endpoint {
    storage_account_id                    = azurerm_storage_account.storage_account.id
    queue_name                            = azurerm_storage_queue.storage_queue.name
    queue_message_time_to_live_in_seconds = 60
  }
  
  # subject_filter {
  #   subject_begins_with = ""
  #   subject_ends_with   = ""
  #   case_sensitive      = false
  # }

  # advanced_filter {}

  # delivery_identity {}

  # delivery_property {}

  # dead_letter_identity {}

  # storage_blob_dead_letter_destination {}
}

output "eventgrid_topic_endpoint" {
  value = azurerm_eventgrid_topic.eventgrid_topic.endpoint
}

output "eventgrid_topic_primary_access_key" {
  value = azurerm_eventgrid_topic.eventgrid_topic.primary_access_key
}
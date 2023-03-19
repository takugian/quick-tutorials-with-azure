provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "random_integer" "random_integer" {
  min = 10000
  max = 99999
}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                                  = "cosmosdb-account-${random_integer.random_integer.result}"
  location                              = azurerm_resource_group.resource_group.location
  resource_group_name                   = azurerm_resource_group.resource_group.name
  offer_type                            = "Standard"
  kind                                  = "MongoDB"
  mongo_server_version                  = "4.2"
  enable_free_tier                      = true
  enable_automatic_failover             = true
  network_acl_bypass_for_azure_services = true
  ip_range_filter                       = module.myip.address
  public_network_access_enabled         = true
  is_virtual_network_filter_enabled     = true
  # network_acl_bypass_ids                = [""]

  # virtual_network_rule {
  #   id = ""
  #   ignore_missing_vnet_service_endpoint = false
  # }

  # key_vault_key_id           = ""
  # analytical_storage_enabled = false

  # capacity {
  #   total_throughput_limit = 1000
  # }

  # default_identity_type = "UserAssignedIdentity"

  # identity {}

  # cors_rule {}

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Eventual" // BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix
    # max_interval_in_seconds = 300
    # max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.resource_group.location
    failover_priority = 0
    zone_redundant    = false
  }

  # analytical_storage {
  #   schema_type = ""
  # }

  # backup {
  #   type                = ""
  #   interval_in_minutes = 1440
  #   retention_in_hours  = 720
  #   storage_redundancy  = ""
  # }

  # restore {
  #   source_cosmosdb_account_id = ""
  #   restore_timestamp_in_utc   = ""
  #   database {
  #     name             = ""
  #     collection_names = [""]
  #   }
  # }
}

resource "azurerm_cosmosdb_mongo_database" "cosmosdb_mongo_database" {
  name                = "cosmosdb-mongo-database"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  throughput          = 400

  # autoscale_settings {
  #   max_throughput = 1000
  # }
}

resource "azurerm_cosmosdb_mongo_collection" "cosmosdb_mongo_collection" {
  name                = "cosmosdb-mongo-collection"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_mongo_database.cosmosdb_mongo_database.name
  shard_key           = "uniqueKey"
  default_ttl_seconds = -1
  throughput          = 400
  # analytical_storage_ttl = -1

  index {
    keys   = ["_id"]
    unique = true
  }

  # autoscale_settings {
  #   max_throughput = 1000
  # }
}

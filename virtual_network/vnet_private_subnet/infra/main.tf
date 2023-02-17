provider "azurerm" {
    subscription_id = var.SUBSCRIPTION_ID
    tenant_id = var.TENANT_ID
    features { }
}

resource "azurerm_resource_group" "resource_group" {
    name        = var.RESOURCE_GROUP
    location    = var.LOCATION  
}

resource "azurerm_network_security_group" "security_group" {
    name                = "security_group_default"
    location            = var.LOCATION
    resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network" "virtual_network" {
    name                = "virtual_network_default"
    location            = var.LOCATION
    resource_group_name = azurerm_resource_group.resource_group.name
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["10.0.0.4", "10.0.0.5"]

    subnet {
        name            = "private_subnet_1"
        address_prefix  = "10.0.1.0/24"
    }

    subnet {
        name            = "private_subnet_2"
        address_prefix  = "10.0.2.0/24"
        security_group  = azurerm_network_security_group.security_group.id
    }

    tags = {
        environment     = "development"
    }

    # ddos_protection_plan {
    #     id              =
    #     enable          = 
    # }

}
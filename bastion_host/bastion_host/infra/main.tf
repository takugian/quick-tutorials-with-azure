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

resource "azurerm_public_ip" "public_ip" {
  name                = "bastion-host-pip"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "bastion-host-default"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP

  ip_configuration {
    name                 = "bastion-host-config"
    subnet_id            = var.BASTION_SUBNET_ID
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

locals {
  gateway_ip_configuration_name  = "public-application-gateway-gateway_ip_configuration"
  frontend_port_name             = "public-application-gateway-frontend-port"
  frontend_ip_configuration_name = "public-application-gateway-frontend-ip-configuration"
  backend_address_pool_name      = "public-application-gateway-backend-address-pool"
  backend_http_setting_name      = "public-application-gateway-backend-http-setting"
  listener_name                  = "public-application-gateway-listener"
  request_routing_rule_name      = "public-application-gateway-request-routing-rule"
  redirect_configuration_name    = "public-application-gateway-redirect-configuration"
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION

  tags = {
    environment = "development"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-application-gateway-pip"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "application_gateway" {
  name                = "public-application-gateway-agtw"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resource_group.name
  # zones = [ "value" ]

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  # autoscale_configuration {
  #     min_capacity                    = 2
  #     max_capacity                    = 4
  # }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.FRONTEND_SUBNET_ID
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = var.BACKEND_PATH
    port                  = var.BACKEND_PORT
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name
    # include_path                    = 
    # include_query_string            =  
  }

}

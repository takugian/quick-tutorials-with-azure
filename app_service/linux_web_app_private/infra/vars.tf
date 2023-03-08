variable "SUBSCRIPTION_ID" {

}

variable "TENANT_ID" {

}

variable "RESOURCE_GROUP" {
  default = "quicktutorials-app_service-rest_api_nodejs"
}

variable "LOCATION" {
  default = "BrazilSouth"
}

variable "WEB_APP_SUBNET_ID" {
  description = "The subnet must be delegated to Microsoft.Web/serverFarms"
  default     = "/subscriptions/4c3770ef-a15d-4b73-b8fb-1443b98f7ed8/resourceGroups/quicktutorials-virtual_network-vnet_private_subnet/providers/Microsoft.Network/virtualNetworks/virtual_network_default/subnets/private_subnet_2"
}

variable "PRIVATE_ENDPOINT_SUBNET_ID" {
  default = "/subscriptions/4c3770ef-a15d-4b73-b8fb-1443b98f7ed8/resourceGroups/quicktutorials-virtual_network-vnet_private_subnet/providers/Microsoft.Network/virtualNetworks/virtual_network_default/subnets/private_subnet_1"
}

variable "DOCKER_REGISTRY_SERVER_USERNAME" {
  default = "containerregistryps40g1"
}

variable "DOCKER_REGISTRY_SERVER_PASSWORD" {

}

variable "SUBSCRIPTION_ID" {

}

variable "TENANT_ID" {

}

variable "RESOURCE_GROUP" {
  default = "quicktutorials-application_gateway-public_application_gateway"
}

variable "LOCATION" {
  default = "BrazilSouth"
}

variable "FRONTEND_SUBNET_ID" {
  default = "/subscriptions/4c3770ef-a15d-4b73-b8fb-1443b98f7ed8/resourceGroups/quicktutorials-virtual_network-vnet_private_subnet/providers/Microsoft.Network/virtualNetworks/virtual_network_default/subnets/private_subnet_1"
}

variable "BACKEND_PATH" {
  default = "/path1/"
}

variable "BACKEND_PORT" {
  default = 3070
}
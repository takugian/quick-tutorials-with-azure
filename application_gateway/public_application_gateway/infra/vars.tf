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

}

variable "BACKEND_PATH" {
  default = "/path1/"
}

variable "BACKEND_PORT" {
  default = 3070
}
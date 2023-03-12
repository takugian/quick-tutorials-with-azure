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
}

variable "PRIVATE_ENDPOINT_SUBNET_ID" {
}

variable "DOCKER_REGISTRY_SERVER_USERNAME" {
  default = "containerregistryps40g1"
}

variable "DOCKER_REGISTRY_SERVER_PASSWORD" {

}

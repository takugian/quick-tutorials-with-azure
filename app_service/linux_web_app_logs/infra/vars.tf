variable "SUBSCRIPTION_ID" {

}

variable "TENANT_ID" {

}

variable "RESOURCE_GROUP" {
  default = "quicktutorials-app_service-linux_web_app_logs"
}

variable "LOCATION" {
  default = "BrazilSouth"
}

variable "DOCKER_REGISTRY_SERVER_USERNAME" {
  default = "containerregistryps40g1"
}

variable "DOCKER_REGISTRY_SERVER_PASSWORD" {
  sensitive = true
}

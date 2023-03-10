variable "SUBSCRIPTION_ID" {

}

variable "TENANT_ID" {

}

variable "RESOURCE_GROUP" {
  default = "quicktutorials-app_service-linux_web_app_source_control"
}

variable "LOCATION" {
  default = "BrazilSouth"
}

variable "REPO_URL" {
  default = "https://github.com/takugian/rest_nodejs_api"
}

variable "REPO_BRANCH" {
  default = "mock"
}

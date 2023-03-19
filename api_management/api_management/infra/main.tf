provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_api_management" "api_management" {
  name                = "api-management"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  publisher_name      = "My Company"
  publisher_email     = "company@terraform.io"
  sku_name            = "Developer_1"

  additional_location {

  }

  certificate {

  }

  min_api_version = ""
  zones           = [""]

  identity {

  }

  hostname_configuration {

  }

  notification_sender_email = ""

  public_network_access_enabled = true

  virtual_network_type = "None"

  virtual_network_configuration {

  }
}

resource "azurerm_api_management_api" "api_management_api" {
  name                = "api-management-api"
  resource_group_name = azurerm_resource_group.resource_group.name
  api_management_name = azurerm_api_management.api_management.name
  revision            = "1"
  display_name        = "Example API"
  path                = "example"
  protocols           = ["https"]

  contact {

  }

  description = ""

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }

  license {

  }

  oauth2_authorization {

  }

  openid_authentication {

  }

  service_url = ""

  subscription_key_parameter_names {

  }

  terms_of_service_url = ""
  version              = ""
  version_set_id       = ""
  revision_description = ""
  source_api_id        = ""

}

resource "azurerm_api_management_api_operation" "api_management_api_operation" {
  operation_id        = "user-delete"
  api_name            = azurerm_api_management_api.api_management_api.name
  api_management_name = azurerm_api_management_api.api_management_api.api_management_name
  resource_group_name = azurerm_api_management_api.api_management_api.resource_group_name
  display_name        = "Delete User Operation"
  method              = "DELETE"
  url_template        = "/users/{id}/delete"
  description         = "This can only be done by the logged in user."

  request {

  }

  response {
    status_code = 200
  }

  template_parameter {

  }
}

resource "azurerm_api_management_api_operation_tag" "api_management_api_operation_tag" {
  name             = "example-Tag"
  api_operation_id = azurerm_api_management_api_operation.api_management_api_operation.id
  display_name     = "example-Tag"
}

resource "azurerm_api_management_api_release" "api_management_api_release" {
  name   = "example-Api-Release"
  api_id = azurerm_api_management_api.api_management_api.id
  notes  = ""
}

resource "azurerm_api_management_api_schema" "api_management_api_schema" {
  api_name            = azurerm_api_management_api.api_management_api.name
  api_management_name = azurerm_api_management_api.api_management_api.api_management_name
  resource_group_name = azurerm_api_management_api.api_management_api.resource_group_name
  schema_id           = "example-schema"
  content_type        = "application/vnd.ms-azure-apim.xsd+xml"
  value               = file("api_management_api_schema.xml")
  components          = ""
  definitions         = ""
}

resource "azurerm_api_management_tag" "api_management_tag" {
  api_management_id = azurerm_api_management.api_management.id
  name              = "example-tag"
}

resource "azurerm_api_management_api_tag" "api_management_api_tag" {
  api_id = azurerm_api_management_api.api_management_api.id
  name   = azurerm_api_management_tag.api_management_api.name
}

resource "azurerm_api_management_api_tag_description" "api_management_api_tag_description" {
  api_tag_id                = azurerm_api_management_tag.api_management_tag.id
  description               = "This is an example description"
  external_docs_url         = "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs"
  external_docs_description = "This is an example external docs description"
}

resource "azurerm_api_management_backend" "api_management_backend" {
  name                = "example-backend"
  resource_group_name = azurerm_resource_group.resource_group.name
  api_management_name = azurerm_api_management.api_management.name
  protocol            = "http"
  url                 = "https://backend"
}

provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

resource "azurerm_public_ip" "public_ip" {
  resource_group_name = var.RESOURCE_GROUP
  location            = var.LOCATION
  name                = "public-ip"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "network_interface" {
  resource_group_name = var.RESOURCE_GROUP
  location            = var.LOCATION
  name                = "network-interface"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.SUBNET_ID
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  resource_group_name             = var.RESOURCE_GROUP
  location                        = var.LOCATION
  name                            = "linux-virtual-machine"
  size                            = "Standard_F2"
  admin_username                  = var.ADMIN_USERNAME
  admin_password                  = var.ADMIN_PASSWORD
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.network_interface.id,
  ]

  #   admin_ssh_key {
  #     username   = var.ADMIN_USERNAME
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

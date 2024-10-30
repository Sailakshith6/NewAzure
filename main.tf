provider "azurerm" {
  features {}
  # Required properties for Azure authentication
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

data "azurerm_resource_group" "example" {
  name     = var.resource_group_name
}

data "azurerm_virtual_network" "example" {
  name                = var.virtual_network
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "example" {
  name                 = var.subnet
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
}

resource "azurerm_network_interface" "example" {
  name                = "${var.vm_name}-nic"
  location            =  var.location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size               = var.vm_size
  admin_username      = var.vm_username
  admin_password      = var.password
  disable_password_authentication = false

  os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Use the storage_image_reference block to set the image ID
  #source_image_reference  {
    source_image_id = var.private_image_id  # Use the variable here
  
}

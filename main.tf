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
  vm_size               = var.vm_size
  admin_username      = var.vm_username
  admin_password      = var.password

  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"  # This is correct as we are creating from an image
    managed_disk_type = "Premium_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # Use the storage_image_reference block to set the image ID
  #source_image_reference  {
    source_image_id = var.private_image_id  # Use the variable here
  
}

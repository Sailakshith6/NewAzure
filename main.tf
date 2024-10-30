provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

data "azurerm_resource_group" "example" {
  name = var.resource_group_name
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
  location            = var.location
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
  size                  = var.vm_size
  admin_username        = var.vm_username
  admin_password        = var.password
  disable_password_authentication = false

  os_disk {
    name                = "${var.vm_name}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = "Premium_LRS"
    
    # Reference the private image ID directly
    source_image_id     = var.private_image_id
  }
}

resource "azurerm_public_ip" "example" {
  name                = "${var.vm_name}-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_managed_disk" "additional_disk" {
  count                = var.attach_data_disk ? 1 : 0
  name                 = "${var.vm_name}-data-disk"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  storage_account_type = "Premium_LRS"
  disk_size_gb        = var.disk_size  # Specify disk size
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  count               = var.attach_data_disk ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.additional_disk[count.index].id
  virtual_machine_id  = azurerm_linux_virtual_machine.example.id
  lun                 = 1  # Start from 1 for additional disks
  caching             = "ReadWrite"
}

output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}

output "network_interface_name" {
  value = azurerm_network_interface.example.name
}

output "private_ip_address" {
  value = azurerm_network_interface.example.private_ip_address
}

output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.example.id
}

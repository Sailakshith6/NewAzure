terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.75.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

data "azurerm_resource_group" "hcmxexample" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "hcmxexample" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
  location            = var.location
  allocation_method   = "Dynamic"
  domain_name_label   = var.domain_name_label
}

data "azurerm_virtual_network" "hcmxexample" {
  name                = var.virtual_network
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
}

data "azurerm_subnet" "hcmxexample" {
  name                 = var.subnet
  resource_group_name  = data.azurerm_resource_group.hcmxexample.name
  virtual_network_name = data.azurerm_virtual_network.hcmxexample.name
}

resource "azurerm_network_interface" "hcmxexample" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.hcmxexample.name

  ip_configuration {
    name                          = var.vm_name
    subnet_id                     = data.azurerm_subnet.hcmxexample.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hcmxexample.id
  }
}

resource "azurerm_linux_virtual_machine" "hcmxexample" {
  count = var.os_type == "linux" ? 1 : 0
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password      = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.hcmxexample.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.type_of_storage
    create_option        = "FromImage"  # Use FromImage for OS disks
  }

  source_image_reference {
    id = var.private_image_id  # Use the resource ID of your private image
  }
}

resource "azurerm_windows_virtual_machine" "hcmxexample" {
  count = var.os_type == "windows" ? 1 : 0
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.hcmxexample.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.type_of_storage
    create_option        = "FromImage"  # Use FromImage for OS disks
  }

  source_image_reference {
    id = var.private_image_id  # Use the resource ID of your private image
  }
}

resource "azurerm_managed_disk" "additional_disk" {
  count                = var.attach_data_disk ? 1 : 0  # Only create if specified
  name                 = "${var.vm_name}-data-disk"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.hcmxexample.name
  storage_account_type = var.type_of_storage
  disk_size_gb        = var.disk_size  # Size for the additional data disk
  create_option        = "Empty"        # Set to create an empty managed disk
}

resource "azurerm_virtual_machine_data_disk_attachment" "hcmxexample" {
  count = var.attach_data_disk ? 1 : 0  # Only attach if specified
  managed_disk_id    = azurerm_managed_disk.additional_disk[count.index].id
  virtual_machine_id = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
  lun                = 1  # Start from 1 for additional disks
  caching            = "ReadWrite"
}

output "public_ip_address" {
  value = azurerm_public_ip.hcmxexample.ip_address
}

output "network_interface_name" {
  value = azurerm_network_interface.hcmxexample.name
}

output "private_ip_address" {
  value = azurerm_network_interface.hcmxexample.private_ip_address
}

output "primary_dns_name" {
  value = azurerm_public_ip.hcmxexample.fqdn
}

output "virtual_machine_id" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
}

output "cloud_instance_id" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
}

output "data_disk_name" {
  value = var.attach_data_disk ? azurerm_managed_disk.additional_disk[0].name : "No data disk attached"
}

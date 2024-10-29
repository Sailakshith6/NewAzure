terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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

# Determine the source of the image (public or private)
resource "azurerm_linux_virtual_machine" "hcmxexample" {
  count               = var.os_type == "linux" && var.image_source == "public" ? 1 : 0
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
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.os_version
  }
}

resource "azurerm_private_image" "hcmxexample" {
  count               = var.os_type == "linux" && var.image_source == "private" ? 1 : 0
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
  location            = var.location
  source_image_reference {
    id = var.private_image_id
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_windows_virtual_machine" "hcmxexample" {
  count               = var.os_type == "windows" && var.image_source == "public" ? 1 : 0
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
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.os_version
  }
}

resource "azurerm_private_windows_image" "hcmxexample" {
  count               = var.os_type == "windows" && var.image_source == "private" ? 1 : 0
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
  location            = var.location
  source_image_reference {
    id = var.private_image_id
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_managed_disk" "hcmxexample" {
  name                 = "${var.vm_name}-disk"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.hcmxexample.name
  storage_account_type = var.type_of_storage
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "hcmxexample" {
  managed_disk_id    = azurerm_managed_disk.hcmxexample.id
  virtual_machine_id = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
  lun                = "10"
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

output "data_disk_name" {
  value = azurerm_managed_disk.hcmxexample.name
}


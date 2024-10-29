# Specify required providers
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

# Data sources and resources for network configuration
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

# Define Linux VM with optional custom image
resource "azurerm_linux_virtual_machine" "hcmxexample" {
  count               = var.os_type == "linux" ? 1 : 0
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
  }

  dynamic "source_image_reference" {
    for_each = var.image_id != "" ? [1] : []
    content {
      id = var.image_id
    }
  }

  source_image_reference {
    publisher = var.image_id == "" ? var.publisher : null
    offer     = var.image_id == "" ? var.offer : null
    sku       = var.image_id == "" ? var.sku : null
    version   = var.image_id == "" ? var.os_version : null
  }
}

# Define Windows VM with optional custom image
resource "azurerm_windows_virtual_machine" "hcmxexample" {
  count               = var.os_type == "windows" ? 1 : 0
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

  dynamic "source_image_reference" {
    for_each = var.image_id != "" ? [1] : []
    content {
      id = var.image_id
    }
  }

  source_image_reference {
    publisher = var.image_id == "" ? var.publisher : null
    offer     = var.image_id == "" ? var.offer : null
    sku       = var.image_id == "" ? var.sku : null
    version   = var.image_id == "" ? var.os_version : null
  }
}

# Managed Disk
resource "azurerm_managed_disk" "hcmxexample" {
  name                 = "${var.vm_name}-disk"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.hcmxexample.name
  storage_account_type = var.type_of_storage
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
}

# Data Disk Attachment
resource "azurerm_virtual_machine_data_disk_attachment" "hcmxexample" {
  managed_disk_id    = azurerm_managed_disk.hcmxexample.id
  virtual_machine_id = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
  lun                = 10
  caching            = "ReadWrite"
}

# Data sources for Public IP and Network Interface
data "azurerm_public_ip" "hcmxexample" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
}

data "azurerm_network_interface" "hcmxexample" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.hcmxexample.name
}

# Outputs
output "public_ip_address" {
  value = data.azurerm_public_ip.hcmxexample.ip_address
}

output "network_interface_name" {
  value = azurerm_network_interface.hcmxexample.name
}

output "private_ip_address" {
  value = data.azurerm_network_interface.hcmxexample.private_ip_address
}

output "primary_dns_name" {
  value = data.azurerm_public_ip.hcmxexample.fqdn
}

output "virtual_machine_id" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
}

output "cloud_instance_id" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.hcmxexample[0].id : azurerm_windows_virtual_machine.hcmxexample[0].id
}

output "data_disk_name" {
  value = azurerm_managed_disk.hcmxexample.name
}

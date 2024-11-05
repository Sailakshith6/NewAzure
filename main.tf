provider "random" {}

resource "random_string" "vm_suffix" {
  length  = 6
  special = false
  upper   = false
}

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
  name                = "${var.vm_name}-${random_string.vm_suffix.result}-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "${var.vm_name}-${random_string.vm_suffix.result}"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_public_ip" "example" {
  name                = "${var.vm_name}-${random_string.vm_suffix.result}-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  domain_name_label   = "${var.domain_name_label}-${random_string.vm_suffix.result}"

 timeouts {
    create = "10m"  # Wait up to 10 minutes for the creation of the public IP
    delete = "10m"  # Wait up to 10 minutes for the deletion of the public IP
  }
}

resource "azurerm_linux_virtual_machine" "linux_example_public" {
  count               = var.os_type == "linux" && var.image_source == "public" ? 1 : 0
  name                 = "${var.vm_name}-${random_string.vm_suffix.result}"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                 = var.vm_size
  admin_username       = var.vm_username
  admin_password       = var.password
  disable_password_authentication = false

  # Use public image reference if using public image
  dynamic "source_image_reference" {
    for_each = var.image_source == "public" ? [1] : []
    content {
      publisher = var.publisher
      offer     = var.offer
      sku       = var.sku
      version   = var.os_version
    }
  }

  os_disk {
    name                = "${var.vm_name}-${random_string.vm_suffix.result}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_linux_virtual_machine" "linux_example_private" {
  count               = var.os_type == "linux" && var.image_source == "private" ? 1 : 0
  name                 = "${var.vm_name}-${random_string.vm_suffix.result}"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                 = var.vm_size
  admin_username       = var.vm_username
  admin_password       = var.password
  disable_password_authentication = false
  source_image_id     = var.private_image_id

  os_disk {
    name                = "${var.vm_name}-${random_string.vm_suffix.result}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_windows_virtual_machine" "windows_example_public" {
  count               = var.os_type == "windows" && var.image_source == "public" ? 1 : 0
  name                 = "${var.vm_name}-${random_string.vm_suffix.result}"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                 = var.vm_size
  admin_username       = var.vm_username
  admin_password       = var.password

  # Use public image reference if using public image
    dynamic "source_image_reference" {
      for_each = var.image_source == "public" ? [1] : []
      content {
        publisher = var.publisher
        offer     = var.offer
        sku       = var.sku
        version   = var.os_version
      }
    }

  os_disk {
    name                = "${var.vm_name}-${random_string.vm_suffix.result}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_windows_virtual_machine" "windows_example_private" {
  count               = var.os_type == "windows" && var.image_source == "private" ? 1 : 0
  name                 = "${var.vm_name}-${random_string.vm_suffix.result}"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                 = var.vm_size
  admin_username       = var.vm_username
  admin_password       = var.password
  source_image_id     = var.private_image_id

  os_disk {
    name                = "${var.vm_name}-${random_string.vm_suffix.result}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_managed_disk" "additional_disk" {
  count                = var.attach_data_disk ? 1 : 0
  name                 = "${var.vm_name}-${random_string.vm_suffix.result}-data-disk"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  storage_account_type = var.type_of_storage
  disk_size_gb        = var.disk_size
  create_option       = "Empty"  # Specify the create_option
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
    count              = var.attach_data_disk && (
                      (var.os_type == "linux" && var.image_source == "public" && length(azurerm_linux_virtual_machine.linux_example_public) > 0) || 
                      (var.os_type == "linux" && var.image_source == "private" && length(azurerm_linux_virtual_machine.linux_example_private) > 0) ||
                      (var.os_type == "windows" && var.image_source == "public" && length(azurerm_windows_virtual_machine.windows_example_public) > 0) ||
                      (var.os_type == "windows" && var.image_source == "private" && length(azurerm_windows_virtual_machine.windows_example_private) > 0)
                      ) ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.additional_disk[count.index].id
  virtual_machine_id = var.os_type == "linux" ? (var.image_source == "public" && length(azurerm_linux_virtual_machine.linux_example_public) > 0 ? azurerm_linux_virtual_machine.linux_example_public[0].id : var.image_source == "private" && length(azurerm_linux_virtual_machine.linux_example_private) > 0 ? azurerm_linux_virtual_machine.linux_example_private[0].id : null) : (var.image_source == "public" && length(azurerm_windows_virtual_machine.windows_example_public) > 0 ? azurerm_windows_virtual_machine.windows_example_public[0].id : var.image_source == "private" && length(azurerm_windows_virtual_machine.windows_example_private) > 0 ? azurerm_windows_virtual_machine.windows_example_private[0].id : null)
  lun                 = 1  # Start from 1 for additional disks
  caching             = "ReadWrite"  # Specify caching option
}

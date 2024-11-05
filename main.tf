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
    name                          = "${var.vm_name}"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_public_ip" "example" {
  name                = "${var.vm_name}-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  domain_name_label   = "${var.domain_name_label}"

 timeouts {
    create = "10m"  # Wait up to 10 minutes for the creation of the public IP
    delete = "10m"  # Wait up to 10 minutes for the deletion of the public IP
  }
}

resource "azurerm_linux_virtual_machine" "linux_example" {
  count                = var.os_type == "linux" ? 1 : 0
  name                 = "${var.vm_name}"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                 = var.vm_size
  admin_username       = var.vm_username
  admin_password       = var.password
  disable_password_authentication = false

  # Use public image if the variable is set to "public"
  source_image_id = var.image_source == "public" ? null : var.private_image_id

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
    name                = "${var.vm_name}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_windows_virtual_machine" "windows_example" {
  count                = var.os_type == "windows" ? 1 : 0
  name                 = "${var.vm_name}"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                 = var.vm_size
  admin_username       = var.vm_username
  admin_password       = var.password

  # Use public image if the variable is set to "public"
  source_image_id = var.image_source == "public" ? null : var.private_image_id

  os_disk {
    name                = "${var.vm_name}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = var.type_of_storage
  }
}

resource "azurerm_managed_disk" "additional_disk" {
  count                = var.attach_data_disk ? 1 : 0
  name                 = "${var.vm_name}-data-disk"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.example.name
  storage_account_type = var.type_of_storage
  disk_size_gb        = var.disk_size
  create_option       = "Empty"  # Specify the create_option
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  count               = var.attach_data_disk ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.additional_disk[count.index].id
  virtual_machine_id  = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_example[0].id : azurerm_windows_virtual_machine.windows_example[0].id
  lun                 = 1  # Start from 1 for additional disks
  caching             = "ReadWrite"  # Specify caching option
}

output "os_disk_name" {
  value = var.os_type == "linux" && var.image_source == "public" && length(azurerm_linux_virtual_machine.linux_example_public) > 0 ? azurerm_linux_virtual_machine.linux_example_public[0].os_disk[0].name : var.os_type == "linux" && var.image_source == "private" && length(azurerm_linux_virtual_machine.linux_example_private) > 0 ? azurerm_linux_virtual_machine.linux_example_private[0].os_disk[0].name : var.os_type == "windows" && var.image_source == "public" && length(azurerm_windows_virtual_machine.windows_example_public) > 0 ? azurerm_windows_virtual_machine.windows_example_public[0].os_disk[0].name : var.os_type == "windows" && var.image_source == "private" && length(azurerm_windows_virtual_machine.windows_example_private) > 0 ? azurerm_windows_virtual_machine.windows_example_private[0].os_disk[0].name : null
}

output "virtual_machine_name" {
  value = var.os_type == "linux" && var.image_source == "public" && length(azurerm_linux_virtual_machine.linux_example_public) > 0 ? azurerm_linux_virtual_machine.linux_example_public[0].name : var.os_type == "linux" && var.image_source == "private" && length(azurerm_linux_virtual_machine.linux_example_private) > 0 ? azurerm_linux_virtual_machine.linux_example_private[0].name : var.os_type == "windows" && var.image_source == "public" && length(azurerm_windows_virtual_machine.windows_example_public) > 0 ? azurerm_windows_virtual_machine.windows_example_public[0].name : var.os_type == "windows" && var.image_source == "private" && length(azurerm_windows_virtual_machine.windows_example_private) > 0 ? azurerm_windows_virtual_machine.windows_example_private[0].name : null  # Return null if no applicable VM is found
}

output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address  # Returns a list of all IP addresses
}

output "network_interface_name" {
  value = azurerm_network_interface.example.name
}

output "private_ip_address" {
  value = azurerm_network_interface.example.private_ip_address
}

output "primary_dns_name" {
  value = azurerm_public_ip.example.fqdn  # Returns a list of all FQDNs
}

output "virtual_machine_id" {
  value = var.os_type == "linux" && var.image_source == "public" && length(azurerm_linux_virtual_machine.linux_example_public) > 0 ? azurerm_linux_virtual_machine.linux_example_public[0].id : var.os_type == "linux" && var.image_source == "private" && length(azurerm_linux_virtual_machine.linux_example_private) > 0 ? azurerm_linux_virtual_machine.linux_example_private[0].id : var.os_type == "windows" && var.image_source == "public" && length(azurerm_windows_virtual_machine.windows_example_public) > 0 ? azurerm_windows_virtual_machine.windows_example_public[0].id : var.os_type == "windows" && var.image_source == "private" && length(azurerm_windows_virtual_machine.windows_example_private) > 0 ? azurerm_windows_virtual_machine.windows_example_private[0].id : null
}

output "cloud_instance_id" {
  value = var.os_type == "linux" && var.image_source == "public" && length(azurerm_linux_virtual_machine.linux_example_public) > 0 ? azurerm_linux_virtual_machine.linux_example_public[0].id : var.os_type == "linux" && var.image_source == "private" && length(azurerm_linux_virtual_machine.linux_example_private) > 0 ? azurerm_linux_virtual_machine.linux_example_private[0].id : var.os_type == "windows" && var.image_source == "public" && length(azurerm_windows_virtual_machine.windows_example_public) > 0 ? azurerm_windows_virtual_machine.windows_example_public[0].id : var.os_type == "windows" && var.image_source == "private" && length(azurerm_windows_virtual_machine.windows_example_private) > 0 ? azurerm_windows_virtual_machine.windows_example_private[0].id : null
}

output "data_disk_name" {
  value = var.attach_data_disk ? azurerm_managed_disk.additional_disk[0].name : null
}


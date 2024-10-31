output "os_disk_name" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_example[0].os_disk[0].name : azurerm_windows_virtual_machine.windows_example[0].os_disk[0].name
}

output "vm_name" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_example[0].name : azurerm_windows_virtual_machine.windows_example[0].name
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

output "primary_dns_name" {
  value = azurerm_public_ip.example.fqdn
}

output "virtual_machine_id" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_example[0].id : azurerm_windows_virtual_machine.windows_example[0].id
}

output "cloud_instance_id" {
  value = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_example[0].id : azurerm_windows_virtual_machine.windows_example[0].id
}

output "data_disk_name" {
  value = var.attach_data_disk ? azurerm_managed_disk.additional_disk[0].name : null
}


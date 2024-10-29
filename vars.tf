variable "subscription_id" {
  description = "The subscription ID for Azure."
  type        = string
}

variable "client_id" {
  description = "The client ID for Azure service principal."
  type        = string
}

variable "client_secret" {
  description = "The client secret for Azure service principal."
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID for Azure."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "virtual_network" {
  description = "The name of the virtual network."
  type        = string
}

variable "subnet" {
  description = "The name of the subnet."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
}

variable "vm_username" {
  description = "The admin username for the VM."
  type        = string
}

variable "password" {
  description = "The admin password for the VM."
  type        = string
}

variable "type_of_storage" {
  description = "The type of storage account for the OS disk."
  type        = string
}

variable "image_source" {
  description = "The source of the image (public/private)."
  type        = string
}

variable "private_image_id" {
  description = "The ID of the private image to use."
  type        = string
}

variable "publisher" {
  description = "Publisher of the public image."
  type        = string
}

variable "offer" {
  description = "Offer of the public image."
  type        = string
}

variable "sku" {
  description = "SKU of the public image."
  type        = string
}

variable "os_version" {
  description = "OS version of the public image."
  type        = string
}

variable "disk_size" {
  description = "The size of the disk in GB."
  type        = number
}

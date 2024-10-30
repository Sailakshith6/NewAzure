variable "subscription_id" {
  description = "The subscription ID for the Azure account."
  type        = string
}

variable "client_id" {
  description = "The client ID for Azure authentication."
  type        = string
}

variable "client_secret" {
  description = "The client secret for Azure authentication."
  type        = string
  sensitive   = true  # Mark as sensitive to avoid displaying in logs
}

variable "tenant_id" {
  description = "The tenant ID for the Azure account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "The Azure location for resources."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "vm_username" {
  description = "The admin username for the virtual machine."
  type        = string
}

variable "password" {
  description = "The password for the VM administrator account."
  type        = string
  sensitive   = true  # Mark as sensitive to avoid displaying in logs
}

variable "os_type" {
  description = "The operating system type (linux or windows)."
  type        = string
  # default     = "linux"  # Default can be set to either 'linux' or 'windows'
}

variable "image_source" {
  description = "The source of the VM image (public or private)."
  type        = string
  # default     = "public"
}

variable "private_image_id" {
  description = "The ID of the private image to use if the image source is private."
  type        = string
  # default     = ""  # Leave empty if not using a private image
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
  # default     = "Standard_DS1_v2"  # Example VM size
}

variable "domain_name_label" {
  description = "The domain name label for the public IP."
  type        = string
}

variable "type_of_storage" {
  description = "The type of storage for the OS disk (Standard_LRS, Premium_LRS, etc.)."
  type        = string
  # default     = "Standard_LRS"  # Default storage type
}

variable "publisher" {
  description = "The publisher of the public image."
  type        = string
}

variable "offer" {
  description = "The offer of the public image."
  type        = string
}

variable "sku" {
  description = "The SKU of the public image."
  type        = string
}

variable "os_version" {
  description = "The version of the public image."
  type        = string
}

variable "disk_size" {
  description = "The size of the data disk in GB."
  type        = number
  #default     = 128  # Default disk size
}

variable "attach_data_disk" {
  description = "Flag to attach an additional data disk"
  type        = bool
  default     = true  # Set to true if you want to attach a data disk
}

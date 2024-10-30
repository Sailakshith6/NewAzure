variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "resource_group_name" {}
variable "virtual_network" {}
variable "subnet" {}
variable "vm_name" {}
variable "location" {}
variable "vm_size" {}
variable "vm_username" {}
variable "password" {}
variable "attach_data_disk" {
  type    = bool
  default = false
}
variable "disk_size" {
  type    = number
}
variable "private_image_id" {}  # Variable for the private image ID

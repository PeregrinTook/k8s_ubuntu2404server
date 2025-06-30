variable "pool_name" {
  description = "Name of the libvirt storage pool"
  type        = string
}

variable "vm_net_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vm_net_mode" {
  description = "Mode of the virtual network (e.g., open, nat)"
  type        = string
}

variable "vm_net_domain" {
  description = "DNS domain assigned to the virtual network"
  type        = string
}

variable "vm_net_addresses" {
  description = "CIDR blocks used by the virtual network"
  type        = list(string)
}

variable "ssh_key_path" {
  description = "Default SSH public key path"
  type        = string
  sensitive   = true
}
variable "vms" {
  description = "The list of virtual machines"
  type = list(object({
    hostname           = string
    username           = string
    memory             = number
    vcpu               = number
    ip_inner           = string
    k8s_role           = string
    system_disk_gb     = number
    containerd_disk_gb = number
  }))
}

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

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "vm_memory" {
  description = "Amount of memory (in MB) assigned to the VM."
  type        = number
}

variable "vm_vcpu" {
  description = "Number of virtual CPUs assigned to the VM."
  type        = number
}

variable "vm_hostname" {
  description = "The hostname for the VM (used in the default network interface)."
  type        = string
}

variable "network_id" {
  description = "The network ID for the second network interface."
  type        = string
}

variable "vm_network_hostname" {
  description = "The hostname for the second (private) network interface."
  type        = string
}

variable "system_disk_id" {
  description = "The ID of the system disk volume."
  type        = string
}

variable "containerd_disk_id" {
  description = "The ID of the containerd disk volume."
  type        = string
}

variable "libvirt_cloudinit_disk_id" {
  description = "The ID of the Cloud-Init ISO disk."
  type        = string
}

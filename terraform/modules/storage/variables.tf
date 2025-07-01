variable "volume_template_name" {
  description = "The name of the Libvirt volume created from the template image (e.g., 'ubuntu-template')."
  type        = string
}

variable "template_image_path" {
  description = "The local path to the template QCOW2 image used to create virtual machine disks."
  type        = string
}

variable "pool_name" {
  description = "The name of the Libvirt storage pool where the template volume will be stored."
  type        = string
}

variable "name_vm" {
  description = "Name of the virtual machine."
  type        = string
}

variable "system_disk_gb" {
  description = "System disk size in gigabytes."
  type        = number
}

variable "containerd_disk_gb" {
  description = "Size of the containerd disk in gigabytes."
  type        = number
}


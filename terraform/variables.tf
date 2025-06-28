variable "ssh_key_path" {
  description = "Default SSH public key path"
  type      = string
  sensitive = true
}
variable "vms" {
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
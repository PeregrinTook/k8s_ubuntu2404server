variable "ssh_key_path" {
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vms" {
  description = "List of VMs with unique configs"
  default = [
    {
      name        = "k8s-m"
      hostname    = "k8s-m"
      config_path = "../config/vm_k8s_m"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.50"
    },
    {
      name        = "k8s-w1"
      hostname    = "k8s-w1"
      config_path = "../config/vm_k8s_w1"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.51"
    },
    {
      name        = "k8s-w2"
      hostname    = "k8s-w2"
      config_path = "../config/vm_k8s_w2"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.52"
    }
  ]
}
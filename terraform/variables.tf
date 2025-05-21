variable "ssh_key_path" {
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vms" {
  description = "List of VMs with unique configs"
  default = [
    {
      hostname    = "k8s-m"
      username    = "ks8"
      config_path = "../config/vm_k8s_m"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.50"
      k8s_role    = "control-plane"
    },
    {
      hostname    = "k8s-w1"
      username    = "ks8"
      config_path = "../config/vm_k8s_w1"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.51"
      k8s_role    = "worker"
    },
    {
      hostname    = "k8s-w2"
      username    = "ks8"
      config_path = "../config/vm_k8s_w2"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.52"
      k8s_role    = "worker"
    },
    {
      hostname    = "k8s-m2"
      username    = "ks8"
      config_path = "../config/vm_k8s_m2"
      memory      = 4096
      vcpu        = 2
      ip_inner    = "192.168.100.53"
      k8s_role    = "control-plane"
    }
  ]
}
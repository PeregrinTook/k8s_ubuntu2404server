variable "ssh_key_path" {
  description = "Default SSH public key path"
  default     = "~/.ssh/id_rsa.pub"
  sensitive   = true
}

variable "vms" {
  description = "List of VMs with unique configs"
  default = [
    {
      hostname           = "k8s-master"
      username           = "ks8"
      memory             = 4096
      vcpu               = 2
      ip_inner           = "192.168.100.50"
      k8s_role           = "control-plane"
      system_disk_gb     = 10
      containerd_disk_gb = 10
    },
    {
      hostname           = "k8s-worker1"
      username           = "ks8"
      memory             = 2048
      vcpu               = 2
      ip_inner           = "192.168.100.51"
      k8s_role           = "worker"
      system_disk_gb     = 20
      containerd_disk_gb = 30
    },
    {
      hostname           = "k8s-worker2"
      username           = "ks8"
      memory             = 2048
      vcpu               = 2
      ip_inner           = "192.168.100.52"
      k8s_role           = "worker"
      system_disk_gb     = 20
      containerd_disk_gb = 30
    },
    {
      hostname           = "tester"
      username           = "ks8"
      memory             = 4096
      vcpu               = 2
      ip_inner           = "192.168.100.53"
      k8s_role           = "worker"
      system_disk_gb     = 20
      containerd_disk_gb = 30
    },
    # {
    #   hostname    = "k8s-worker3"
    #   username    = "ks8"
    #   memory      = 4096
    #   vcpu        = 2
    #   ip_inner    = "192.168.100.54"
    #   k8s_role    = "worker"
    #   system_disk_gb = 20
    #   containerd_disk_gb = 30
    # }
  ]
}
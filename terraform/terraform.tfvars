ssh_key_path = "~/.ssh/id_ed25519.pub"

#for joining VM to cluster k8s_role should be  worker or control-plane
vms = [
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
  # {
  #   hostname           = "k8s-worker2"
  #   username           = "ks8"
  #   memory             = 2048
  #   vcpu               = 2
  #   ip_inner           = "192.168.100.52"
  #   k8s_role           = "worker"
  #   system_disk_gb     = 20
  #   containerd_disk_gb = 30
  # },
  # {
  #   hostname           = "tester"
  #   username           = "ks8"
  #   memory             = 2048
  #   vcpu               = 2
  #   ip_inner           = "192.168.100.53"
  #   k8s_role           = "tester"
  #   system_disk_gb     = 20
  #   containerd_disk_gb = 30
  # },
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


pool_name        = "for_k8s_vms"
vm_net_name      = "vm_open_k8s"
vm_net_mode      = "open"
vm_net_domain    = "internal_k8s"
vm_net_addresses = ["192.168.100.0/24"]

volume_template_name = "ubuntu-template"
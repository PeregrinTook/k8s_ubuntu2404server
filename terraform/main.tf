provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "vm_net" {
  name      = "vm_open_k8s"
  mode      = "open"
  domain    = "internal_k8s"
  addresses = ["192.168.100.0/24"]
}

resource "libvirt_volume" "ubuntu_disk" {
  for_each = { for vm in var.vms : vm.name => vm }

  name   = "${each.value.name}_disk.qcow2"
  pool   = "default"
  source = "/home/alexkol/k8s_ubuntu2404server/images/ubuntu-template.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "ubuntu_init" {
  for_each = { for vm in var.vms : vm.name => vm }

  name            = "ubuntu-init-${each.key}-${timestamp()}.iso"
  pool            = "default"
  user_data       = templatefile("${path.module}/${each.value.config_path}/cloud_init.yml", {
    ssh_key = file(var.ssh_key_path)
  })
  network_config  = file("${path.module}/${each.value.config_path}/network_config.yml")

  lifecycle {
    create_before_destroy = true
  }
}

resource "libvirt_domain" "ubuntu_vm" {
  for_each = { for vm in var.vms : vm.name => vm }

  name   = each.value.name
  memory = each.value.memory
  vcpu   = each.value.vcpu
  
  network_interface {
    network_name = "default"
    hostname     = each.value.hostname
  }
  
  network_interface {
    network_id = libvirt_network.vm_net.id
    hostname   = "${each.value.hostname}-private"
  }

  disk {
    volume_id = libvirt_volume.ubuntu_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.ubuntu_init[each.key].id
}



output "VM_info" {
  value = { 
    for vm in var.vms : vm.name => {
      name       = libvirt_domain.ubuntu_vm[vm.name].name
      memory     = libvirt_domain.ubuntu_vm[vm.name].memory
      vcpu       = libvirt_domain.ubuntu_vm[vm.name].vcpu
      mac_inner  = libvirt_domain.ubuntu_vm[vm.name].network_interface[1].mac
      status     = libvirt_domain.ubuntu_vm[vm.name].running
    }
  }
}

variable "ssh_key_path" {
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vms" {
  description = "List of VMs with unique configs"
  default = [
    {
      name        = "k8s-m"
      hostname    = "node1"
      config_path = "../config/vm_k8s_m"
      memory      = 4096
      vcpu        = 2
    },
    {
      name        = "k8s-w1"
      hostname    = "node2"
      config_path = "../config/vm_k8s_w1"
      memory      = 2048
      vcpu        = 2
    },
    {
      name        = "k8s-w2"
      hostname    = "node3"
      config_path = "../config/vm_k8s_w2"
      memory      = 2048
      vcpu        = 2
    }
  ]
}

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "vm_net" {
  name      = "vm_net"
  mode      = "nat"
  domain    = "example.com"
  addresses = ["192.168.122.0/24"]
}

resource "libvirt_volume" "ubuntu_disk" {
  name   = "ubuntu_vm_disk.qcow2"
  pool   = "default"
  source = "/var/lib/libvirt/images/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_domain" "ubuntu_vm" {
  name   = "ubuntu_vm"
  memory = 2048
  vcpu   = 2

  network_interface {
    network_id = libvirt_network.vm_net.id
    hostname   = "ubuntu-vm"
  }

  disk {
    volume_id = libvirt_volume.ubuntu_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
  }

  cloudinit = {
    user_data = <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...your-public-key...==
EOF
  }
}

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
  name      = "vm_open_k8s"
  mode      = "open"
  domain    = "internal_k8s"
  addresses = ["192.168.100.0/24"]
}

# Ресурс для хранения данных виртуальной машины
resource "libvirt_pool" "accessible_pool" {
  name = "accessible_pool"
  type = "dir"

  target {
    path = "/var/lib/libvirt/accessible_images"
  }
}

# Диск виртуальной машины
resource "libvirt_volume" "ubuntu_disk" {
  name   = "ubuntu_vm_disk.qcow2"
  pool   = libvirt_pool.accessible_pool.name
  format = "qcow2"
  size   = 10 # Размер диска в GB, можно подкорректировать
}

# Ресурс Cloud-init диск
resource "libvirt_cloudinit_disk" "ubuntu_init" {
  name      = "ubuntu-init.iso"
  pool      = libvirt_pool.accessible_pool.name
  user_data = <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    ssh_authorized_keys:
      - ${file("/home/alexkol/.ssh/id_rsa.pub")}
EOF
  depends_on = [libvirt_pool.accessible_pool]
}

# Виртуальная машина
resource "libvirt_domain" "ubuntu_vm" {
  name   = "ubuntu_vm"
  memory = 2048
  vcpu   = 2

  network_interface {
    network_id = libvirt_network.vm_net.id
    hostname   = "ubuntu-vm"
  }

  # Подключение создаваемого диска
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

  # Подключение Cloud-init диска
  cloudinit = libvirt_cloudinit_disk.ubuntu_init.id
}

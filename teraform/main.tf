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

# Создаем сеть для виртуальной машины
resource "libvirt_network" "vm_net" {
  name      = "vm_open_k8s"
  mode      = "open"
  domain    = "internal_k8s"
  addresses = ["192.168.100.0/24"]
}

# Диск виртуальной машины
resource "libvirt_volume" "ubuntu_disk" {
  name   = "ubuntu_vm_disk.qcow2"
  pool   = "default"
  source = "/home/alexkol/k8s_ubuntu2404server/images/ubuntu-template.qcow2"
  format = "qcow2"
}

# Ресурс Cloud-init диск
resource "libvirt_cloudinit_disk" "ubuntu_init" {
  name      = "ubuntu-init-${timestamp()}.iso"
  pool      = "default"  # Используем уже существующий default pool
  user_data = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered

  lifecycle {
    create_before_destroy = true
  }
}
# ggh45
# Виртуальная машина
resource "libvirt_domain" "ubuntu_vm" {
  name   = "ubuntu_vm2"
  memory = 2048
  vcpu   = 2
  network_interface {
    network_name = "default"
    hostname     = "ubuntu-vm-nat"
  }
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

# Используем data source для шаблонов cloud-init и network-config

data "template_file" "user_data" {
  template = file("/home/alexkol/k8s_ubuntu2404server/config/cloud_init.yml")
  vars = {
    ssh_key = file("/home/alexkol/.ssh/id_rsa.pub")
  }
}


data "template_file" "network_config" {
  template = file("/home/alexkol/k8s_ubuntu2404server/config/network_config.yml")
}

variable "ssh_key" {
  description = "Path to the public SSH key"
  type        = string
  default     = "/home/alexkol/.ssh/id_rsa.pub"  # Укажите путь к вашему публичному ключу
}

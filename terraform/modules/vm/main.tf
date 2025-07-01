resource "libvirt_domain" "ubuntu_vm" {


  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  network_interface {
    network_name = "default"
    hostname     = var.vm_hostname
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  network_interface {
    network_id = var.network_id
    hostname   = "${var.vm_network_hostname}-private"
  }

  disk {
    volume_id = var.system_disk_id
  }

  disk {
    volume_id = var.containerd_disk_id
  }

  cloudinit = var.libvirt_cloudinit_disk_id
}

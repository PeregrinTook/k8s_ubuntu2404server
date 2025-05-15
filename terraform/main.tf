provider "libvirt" {
  uri = "qemu:///system"
}
resource "libvirt_pool" "k8s_vms_pool" {
  name = "for_k8s_vms"
  type = "dir"

  target {
    path = "/home/alexkol/k8s_ubuntu2404server/for_k8s_vms/"
  }
}

# resource "null_resource" "start_pool" {
#   provisioner "local-exec" {
#     command = "virsh pool-start for_k8s_vms"
#   }
#   depends_on = [libvirt_pool.k8s_vms_pool]
# }


resource "libvirt_network" "vm_net" {
  name      = "vm_open_k8s"
  mode      = "open"
  domain    = "internal_k8s"
  addresses = ["192.168.100.0/24"]
  autostart = true
}

resource "libvirt_volume" "ubuntu_disk" {
  for_each = { for vm in var.vms : vm.name => vm }

  name = "${each.value.name}_disk.qcow2"
  # pool = "default"
  source = "/home/alexkol/k8s_ubuntu2404server/images/ubuntu-template.qcow2"
  pool   = libvirt_pool.k8s_vms_pool.name
  format = "qcow2"
  # size   = 10 * 1024 * 1024 * 1024
  depends_on = [libvirt_pool.k8s_vms_pool]
}

resource "libvirt_cloudinit_disk" "ubuntu_init" {
  for_each = { for vm in var.vms : vm.name => vm }

  name = "ubuntu-init-${each.key}-${timestamp()}.iso"
  # pool = "default"
  pool = libvirt_pool.k8s_vms_pool.name
  user_data = templatefile("${path.module}/${each.value.config_path}/cloud_init.yml", {
    ssh_key  = file(var.ssh_key_path),
    hostname = each.value.hostname
  })
  network_config = file("${path.module}/${each.value.config_path}/network_config.yml")

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [libvirt_pool.k8s_vms_pool]
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
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  network_interface {
    network_id = libvirt_network.vm_net.id
    hostname   = "${each.value.hostname}-private"
  }

  disk {
    volume_id = libvirt_volume.ubuntu_disk[each.key].id
  }

  cloudinit  = libvirt_cloudinit_disk.ubuntu_init[each.key].id
  depends_on = [libvirt_pool.k8s_vms_pool]
}
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.yml"
  content = templatefile("${path.module}/ansible/inventory_template.yml.tpl", {
    master_ip  = var.vms[0].ip_inner,
    worker_ips = slice([for vm in var.vms : vm.ip_inner], 1, length(var.vms))
  })
  depends_on = [libvirt_domain.ubuntu_vm]
}




output "VM_info" {
  value = {
    for vm in var.vms : vm.name => {
      name      = libvirt_domain.ubuntu_vm[vm.name].name
      memory    = libvirt_domain.ubuntu_vm[vm.name].memory
      vcpu      = libvirt_domain.ubuntu_vm[vm.name].vcpu
      mac_inner = libvirt_domain.ubuntu_vm[vm.name].network_interface[1].mac
      status    = libvirt_domain.ubuntu_vm[vm.name].running
      ip_inner  = vm.ip_inner
    }
  }
}



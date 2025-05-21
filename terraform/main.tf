provider "libvirt" {
  uri = "qemu:///system"
}
resource "libvirt_pool" "k8s_vms_pool" {
  name = "for_k8s_vms"
  type = "dir"

  target {
    path = abspath("${path.module}/../for_k8s_vms/")
  }
}

resource "libvirt_network" "vm_net" {
  name      = "vm_open_k8s"
  mode      = "open"
  domain    = "internal_k8s"
  addresses = ["192.168.100.0/24"]
  autostart = true
}

resource "libvirt_volume" "ubuntu_disk" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  name       = "${each.value.hostname}_disk.qcow2"
  source     = "${path.module}/../images/ubuntu-template.qcow2"
  pool       = libvirt_pool.k8s_vms_pool.name
  format     = "qcow2"
  depends_on = [libvirt_pool.k8s_vms_pool]
}

resource "null_resource" "create_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../config_vms_autogen/${each.key}"
  }
  depends_on = [libvirt_volume.ubuntu_disk]
}

resource "null_resource" "cleanup_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/../config_vms_autogen/${each.key}"
  }
  depends_on = [libvirt_volume.ubuntu_disk]
}

resource "local_file" "cloud_init" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  filename = "${path.module}/../config_vms_autogen/${each.key}/cloud_init.yml"
  content = templatefile("${path.module}/../templates/terraform/cloud_user_network_init/cloud_init.yml.tmpl", {
    username = "k8s"
    hostname = each.value.hostname
    ssh_key  = file(var.ssh_key_path)
  })
  depends_on = [null_resource.create_vm_dirs]
}

resource "local_file" "network_config" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  filename = "${path.module}/../config_vms_autogen/${each.key}/network_config.yml"
  content = templatefile("${path.module}/../templates/terraform/cloud_user_network_init/network_config.yml.tmpl", {
    ip_address_inner = each.value.ip_inner
  })
  depends_on = [null_resource.create_vm_dirs]
}

resource "libvirt_cloudinit_disk" "ubuntu_init" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  name           = "ubuntu-init-${each.value.hostname}.iso"
  pool           = libvirt_pool.k8s_vms_pool.name
  user_data      = local_file.cloud_init[each.key].content
  network_config = local_file.network_config[each.key].content

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [libvirt_pool.k8s_vms_pool, local_file.cloud_init, local_file.network_config]
}

resource "libvirt_domain" "ubuntu_vm" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  name   = each.value.hostname
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

# resource "local_file" "ansible_inventory" {

#   filename = "${path.module}/../ansible/inventory.yml"
#   content = templatefile("${path.module}/../ansible/inventory_template.yml.tpl", {
#     masters = [for vm in var.vms : vm if vm.k8s_role == "control-plane"],
#     workers = [for vm in var.vms : vm if vm.k8s_role == "worker"]
#   })
#   depends_on = [libvirt_domain.ubuntu_vm]
# }

output "VM_info" {
  value = {
    for vm in var.vms : vm.hostname => {
      name      = libvirt_domain.ubuntu_vm[vm.hostname].name
      memory    = libvirt_domain.ubuntu_vm[vm.hostname].memory
      vcpu      = libvirt_domain.ubuntu_vm[vm.hostname].vcpu
      mac_inner = libvirt_domain.ubuntu_vm[vm.hostname].network_interface[1].mac
      status    = libvirt_domain.ubuntu_vm[vm.hostname].running
      ip_inner  = vm.ip_inner
    }
  }
}



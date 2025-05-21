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

# resource "libvirt_volume" "ubuntu_disk" {
#   for_each = { for vm in var.vms : vm.hostname => vm }

#   name = "${each.value.hostname}_disk.qcow2"
#   source = "${path.module}/../images/ubuntu-template.qcow2"
#   pool   = libvirt_pool.k8s_vms_pool.name
#   format = "qcow2"
#   depends_on = [libvirt_pool.k8s_vms_pool]
# }

# output "debug_vms_map" {
#   value = { for vm in var.vms : vm.hostname => vm }
# }

######################################
resource "null_resource" "create_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../config_vms/${each.key}"
  }
}
resource "null_resource" "cleanup_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/../config_vms/${each.key}"
  }
}

resource "local_file" "cloud_init" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  filename = "${path.module}/../config_vms/${each.key}/cloud_init.yml"
  content  = templatefile("${path.module}/../templates/terraform/cloud_user_network_init/cloud_init.yml.tmpl", {
    username = "k8s"
    hostname = each.value.hostname
    ssh_key  = file(var.ssh_key_path)
  })
  depends_on = [ null_resource.create_vm_dirs ]
}

resource "local_file" "network_config" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  filename = "${path.module}/../config_vms/${each.key}/network_config.yml"
  content  = templatefile("${path.module}/../templates/terraform/cloud_user_network_init/network_config.yml.tmpl", {
    ip_address_inner = each.value.ip_inner
    # gateway    = var.gateway
  })
}
# ###################################################

# resource "libvirt_cloudinit_disk" "ubuntu_init" {
#   for_each = { for vm in var.vms : vm.hostname => vm }

#   name = "ubuntu-init-${each.value.hostname}.iso"
#   pool = libvirt_pool.k8s_vms_pool.name
#   user_data = templatefile("${path.module}/${each.value.config_path}/cloud_init.yml", {
#     ssh_key  = file(var.ssh_key_path),
#     hostname = each.value.hostname
#   })
#   network_config = file("${path.module}/${each.value.config_path}/network_config.yml")

#   lifecycle {
#     create_before_destroy = true
#   }
#   depends_on = [libvirt_pool.k8s_vms_pool]
# }

# resource "libvirt_domain" "ubuntu_vm" {
#   for_each = { for vm in var.vms : vm.name => vm }

#   name   = each.value.name
#   memory = each.value.memory
#   vcpu   = each.value.vcpu

#   network_interface {
#     network_name = "default"
#     hostname     = each.value.hostname
#   }
#   console {
#     type        = "pty"
#     target_port = "0"
#     target_type = "serial"
#   }

#   network_interface {
#     network_id = libvirt_network.vm_net.id
#     hostname   = "${each.value.hostname}-private"
#   }

#   disk {
#     volume_id = libvirt_volume.ubuntu_disk[each.key].id
#   }

#   cloudinit  = libvirt_cloudinit_disk.ubuntu_init[each.key].id
#   depends_on = [libvirt_pool.k8s_vms_pool]
# }



# resource "local_file" "ansible_inventory" {

#   filename = "${path.module}/../ansible/inventory.yml"
#   content = templatefile("${path.module}/../ansible/inventory_template.yml.tpl", {
#     masters = [for vm in var.vms : vm if vm.k8s_role == "control-plane"],
#     workers = [for vm in var.vms : vm if vm.k8s_role == "worker"]
#   })
#   depends_on = [libvirt_domain.ubuntu_vm]
# }




# output "VM_info" {
#   value = {
#     for vm in var.vms : vm.name => {
#       name      = libvirt_domain.ubuntu_vm[vm.name].name
#       memory    = libvirt_domain.ubuntu_vm[vm.name].memory
#       vcpu      = libvirt_domain.ubuntu_vm[vm.name].vcpu
#       mac_inner = libvirt_domain.ubuntu_vm[vm.name].network_interface[1].mac
#       status    = libvirt_domain.ubuntu_vm[vm.name].running
#       ip_inner  = vm.ip_inner
#     }
#   }
# }



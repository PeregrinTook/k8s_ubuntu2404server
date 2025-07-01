provider "libvirt" {
  uri = "qemu:///system"
}

module "k8s_vms_pool" {
  source           = "./modules/network"
  pool_name        = var.pool_name
  vm_net_name      = var.vm_net_name
  vm_net_domain    = var.vm_net_domain
  vm_net_mode      = var.vm_net_mode
  vm_net_addresses = var.vm_net_addresses
}
module "storage" {
  source   = "./modules/storage"
  for_each = { for vm in var.vms : vm.hostname => vm }

  volume_template_name = var.volume_template_name
  template_image_path  = local.template_image_path
  pool_name            = var.pool_name
  name_vm              = each.key
  system_disk_gb       = each.value.system_disk_gb
  containerd_disk_gb   = each.value.containerd_disk_gb
  depends_on           = [module.k8s_vms_pool]
}

resource "null_resource" "create_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../config_vms_autogen/${each.key}"
  }
  depends_on = [module.storage]
}

resource "null_resource" "cleanup_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/../config_vms_autogen/${each.key}"
  }
  depends_on = [module.storage]
}

resource "local_file" "cloud_init" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  filename = "${path.module}/../config_vms_autogen/${each.key}/cloud_init.yml"
  content = templatefile("${path.module}/../templates/terraform/cloud_user_network_init/cloud_init.yml.tmpl", {
    username = "k8s"
    hostname = each.value.hostname
    ssh_key  = file(lookup(each.value, "ssh_key", var.ssh_key_path))
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
  pool           = module.k8s_vms_pool.pool_name
  user_data      = local_file.cloud_init[each.key].content
  network_config = local_file.network_config[each.key].content

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [module.k8s_vms_pool, local_file.cloud_init, local_file.network_config]
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
    network_id = module.k8s_vms_pool.network_id
    hostname   = "${each.value.hostname}-private"
  }

  disk {
    # volume_id = libvirt_volume.system_disk[each.key].id
    volume_id = module.storage[each.key].system_disk_id
  }

  disk {
    volume_id = module.storage[each.key].containerd_disk_id
  }

  cloudinit  = libvirt_cloudinit_disk.ubuntu_init[each.key].id
  depends_on = [libvirt_cloudinit_disk.ubuntu_init, module.storage]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yml"
  content = templatefile("${path.module}/../templates/ansible/inventory_template.yml.tpl", {
    masters = [
      for vm in var.vms : {
        name = vm.hostname
        ip   = vm.ip_inner
      } if vm.k8s_role == "control-plane"
    ]
    workers = [
      for vm in var.vms : {
        name = vm.hostname
        ip   = vm.ip_inner
      } if vm.k8s_role == "worker"
    ]
    testers = [
      for vm in var.vms : {
        name = vm.hostname
        ip   = vm.ip_inner
      } if vm.k8s_role == "tester"
    ]
    ssh = var.ssh_key_path
  })
  depends_on = [libvirt_domain.ubuntu_vm]
}

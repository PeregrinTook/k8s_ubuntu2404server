# Libvirt provider configuration (connects to system QEMU/KVM)
provider "libvirt" {
  uri = "qemu:///system"
}

# Module for creating the storage pool and virtual network
module "k8s_vms_pool" {
  source           = "./modules/network"
  pool_name        = var.pool_name
  vm_net_name      = var.vm_net_name
  vm_net_domain    = var.vm_net_domain
  vm_net_mode      = var.vm_net_mode
  vm_net_addresses = var.vm_net_addresses
}

# Module that provisions disks for each VM (system and containerd volumes)
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

# Creates a config directory for each VM (for generated cloud-init files)
resource "null_resource" "create_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../config_vms_autogen/${each.key}"
  }
  depends_on = [module.storage]
}

# Cleans up the VM config directories when VMs are destroyed
resource "null_resource" "cleanup_vm_dirs" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/../config_vms_autogen/${each.key}"
  }
  depends_on = [module.storage]
}

# Renders per-VM cloud-init configuration file from a template
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

# Renders per-VM network config file for cloud-init from a template
resource "local_file" "network_config" {
  for_each = { for vm in var.vms : vm.hostname => vm }

  filename = "${path.module}/../config_vms_autogen/${each.key}/network_config.yml"
  content = templatefile("${path.module}/../templates/terraform/cloud_user_network_init/network_config.yml.tmpl", {
    ip_address_inner = each.value.ip_inner
  })
  depends_on = [null_resource.create_vm_dirs]
}

# Creates a cloud-init ISO image for each VM with user data and network config
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

# Creates a libvirt domain (VM) for each node using disks, network, and cloud-init
module "vm" {
  source   = "./modules/vm"
  for_each = { for vm in var.vms : vm.hostname => vm }

  vm_name                   = each.value.hostname
  vm_memory                 = each.value.memory
  vm_vcpu                   = each.value.vcpu
  vm_hostname               = each.value.hostname
  network_id                = module.k8s_vms_pool.network_id
  vm_network_hostname       = "${each.value.hostname}-private"
  system_disk_id            = module.storage[each.key].system_disk_id
  containerd_disk_id        = module.storage[each.key].containerd_disk_id
  libvirt_cloudinit_disk_id = libvirt_cloudinit_disk.ubuntu_init[each.key].id
  depends_on                = [module.storage, libvirt_cloudinit_disk.ubuntu_init]
}

# Generates Ansible inventory file with master/worker/tester IPs for SSH and provisioning
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
  depends_on = [module.vm]
}

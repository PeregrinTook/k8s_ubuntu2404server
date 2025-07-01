output "VM_info" {
  value = {
    for vm in var.vms : vm.hostname => {
      name       = module.vm[vm.hostname].name
      memory     = module.vm[vm.hostname].memory
      vcpu       = module.vm[vm.hostname].vcpu
      mac_inner  = module.vm[vm.hostname].mac_inner
      status     = module.vm[vm.hostname].status
      sys_disk   = module.storage[vm.hostname].system_disk_size_gb
      contd_disk = module.storage[vm.hostname].containerd_disk_size_gb
      ip_inner   = vm.ip_inner
      role       = vm.k8s_role
    }
  }
}

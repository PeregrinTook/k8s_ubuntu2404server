# output "VM_info" {
#   value = {
#     for vm in var.vms : vm.hostname => {
#       name       = libvirt_domain.ubuntu_vm[vm.hostname].name
#       memory     = libvirt_domain.ubuntu_vm[vm.hostname].memory
#       vcpu       = libvirt_domain.ubuntu_vm[vm.hostname].vcpu
#       mac_inner  = libvirt_domain.ubuntu_vm[vm.hostname].network_interface[1].mac
#       status     = libvirt_domain.ubuntu_vm[vm.hostname].running
#       sys_disk   = format("%.0f GiB", libvirt_volume.system_disk[vm.hostname].size / 1024 / 1024 / 1024)
#       contd_disk = format("%.0f GiB", libvirt_volume.containerd_disk[vm.hostname].size / 1024 / 1024 / 1024)
#       ip_inner   = vm.ip_inner
#       role       = vm.k8s_role
#     }
#   }
# }
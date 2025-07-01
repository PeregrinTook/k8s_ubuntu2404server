output "name" {
  value = libvirt_domain.ubuntu_vm.name
}

output "memory" {
  value = libvirt_domain.ubuntu_vm.memory
}

output "vcpu" {
  value = libvirt_domain.ubuntu_vm.vcpu
}

output "mac_inner" {
  value = libvirt_domain.ubuntu_vm.network_interface[1].mac
}

output "status" {
  value = libvirt_domain.ubuntu_vm.running
}

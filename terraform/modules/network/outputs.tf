output "pool_name" { value = libvirt_pool.k8s_vms_pool.name }
output "network_id" { value = libvirt_network.vm_net.id }
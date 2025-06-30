resource "libvirt_pool" "k8s_vms_pool" {
  name = var.pool_name
  type = "dir"
  target {
    path = abspath("${path.module}/../for_k8s_vms/")
  }
}

resource "libvirt_network" "vm_net" {
  name      = var.vm_net_name
  mode      = var.vm_net_mode
  domain    = var.vm_net_domain
  addresses = var.vm_net_addresses
  autostart = true
}


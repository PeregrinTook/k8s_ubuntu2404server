
output "system_disk_id" {
  description = "ID of the system disk volume"
  value       = libvirt_volume.system_disk.id
}

output "containerd_disk_id" {
  description = "ID of the containerd disk volume"
  value       = libvirt_volume.containerd_disk.id
}
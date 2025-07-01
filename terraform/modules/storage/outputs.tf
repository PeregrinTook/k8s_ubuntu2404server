
output "system_disk_id" {
  description = "ID of the system disk volume"
  value       = libvirt_volume.system_disk.id
}

output "containerd_disk_id" {
  description = "ID of the containerd disk volume"
  value       = libvirt_volume.containerd_disk.id
}

output "system_disk_size_gb" {
  value = floor(libvirt_volume.system_disk.size / 1024 / 1024 / 1024)
}

output "containerd_disk_size_gb" {
  value = floor(libvirt_volume.containerd_disk.size / 1024 / 1024 / 1024)
}

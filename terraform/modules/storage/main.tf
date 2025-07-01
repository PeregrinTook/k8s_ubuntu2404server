resource "libvirt_volume" "template" {
  name   = var.volume_template_name #"ubuntu-template"
  source = var.template_image_path  #"${path.module}/../images/ubuntu-template.qcow2"
  pool   = var.pool_name
  format = "qcow2"
}

resource "libvirt_volume" "system_disk" {

  name           = "${var.name_vm}_system.qcow2"
  base_volume_id = libvirt_volume.template.id
  pool           = var.pool_name
  size           = var.system_disk_gb * 1024 * 1024 * 1024
  format         = "qcow2"
  depends_on     = [libvirt_volume.template]
}

resource "libvirt_volume" "containerd_disk" {

  name       = "${var.name_vm}_containerd.qcow2"
  pool       = var.pool_name
  size       = var.containerd_disk_gb * 1024 * 1024 * 1024
  format     = "qcow2"
  depends_on = [libvirt_volume.template]

}


# create a libvirt image
resource "libvirt_volume" "pfsense" {
  name   = "pfsense.qcow2"
  pool   = "${libvirt_pool.vm-pool.name}"
  source = "${var.pfsense_img}"
  format = "qcow2"
}

# Create a root volume (pour agrandir le disk)
resource "libvirt_volume" "pfsense_rootfs" {
  name = "rootfs"
  base_volume_id = "${libvirt_volume.pfsense.id}"
  size = "10000000000"
}

# Create the machine
resource "libvirt_domain" "pfsense" {
  name   = "pfsense"
  memory = "2048"
  vcpu   = 4

  cloudinit = "${libvirt_cloudinit_disk.pfsense_cloudinitiso.id}"

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.pfsense_rootfs.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

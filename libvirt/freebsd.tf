# create a libvirt image
resource "libvirt_volume" "freebsd" {
  name   = "freebsd.qcow2"
  pool   = "${libvirt_pool.vm-pool.name}"
  source = "${var.freebsd_img}"
  format = "qcow2"
}

# Create a root volume (pour agrandir le disk)
resource "libvirt_volume" "freebsd_rootfs" {
  name = "rootfs"
  base_volume_id = "${libvirt_volume.freebsd.id}"
  size = "35000000000"
}

# Create the machine
resource "libvirt_domain" "freebsd" {
  name   = "freebsd"
  memory = "2048"
  vcpu   = 4

  cloudinit = "${libvirt_cloudinit_disk.freebsd_cloudinitiso.id}"

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.freebsd_rootfs.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

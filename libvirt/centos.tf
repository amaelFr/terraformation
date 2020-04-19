# create a libvirt image
resource "libvirt_volume" "centos" {
  name   = "centos.qcow2"
  pool   = "${libvirt_pool.vm-pool.name}"
  source = "/mnt/hgfs/iso/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"
  format = "qcow2"
}

# Create a root volume (pour agrandir le disk)
resource "libvirt_volume" "centos_rootfs" {
  name = "rootfs"
  base_volume_id = "${libvirt_volume.centos.id}"
  size = "11000000000"
}

# Create the machine
resource "libvirt_domain" "centos" {
  name   = "centos"
  memory = "2048"
  vcpu   = 4

  cloudinit = "${libvirt_cloudinit_disk.centos_cloudinitiso.id}"

  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = "${libvirt_volume.centos_rootfs.id}"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

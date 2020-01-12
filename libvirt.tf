
# provider for libvirt
provider "libvirt" {
  uri = "qemu:///system"
}

# create a libvirt pool
resource "libvirt_pool" "ubuntu" {
 name = "ubuntu-pool"
 type = "dir"
 path = "/home/x1/vm/"
}

# create a libvirt image
resource "libvirt_volume" "image-qcow2" {
 name = "ubuntu-amd64.qcow2"
 pool = libvirt_pool.ubuntu.name
 source ="/home/x1/shared/iso/bionic-server-cloudimg-amd64.img"
 format = "qcow2"
}

# add cloudinit disk to pool
resource "libvirt_cloudinit_disk" "commoninit" {
 name = "commoninit.iso"
 pool = libvirt_pool.ubuntu.name
 user_data = data.template_file.user_data.rendered
}

# read the configuration
data "template_file" "user_data" {
 template = file("./cloud_init.cfg")
}

# Create the machine
resource "libvirt_domain" "ubuntu" {
  name = "test-vm-ubuntu"
  memory = "8196"
  vcpu = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    network_name = "default"
  }

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
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
       volume_id = libvirt_volume.image-qcow2.id
  }
  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = "true"
  }
}
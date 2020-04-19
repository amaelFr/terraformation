# # create a libvirt image
# resource "libvirt_volume" "ubuntu18_04" {
#   name   = "ubuntu18_04.qcow2"
#   pool   = "${libvirt_pool.vm-pool.name}"
#   source = "/mnt/hgfs/iso/bionic-server-cloudimg-amd64.img"
#   format = "qcow2"
# }

# # Create a root volume (pour agrandir le disk)
# resource "libvirt_volume" "ubuntu_rootfs" {
#   name = "ubuntu_rootfs"
#   base_volume_id = "${libvirt_volume.ubuntu18_04.id}"
#   size = "10000000000"
# }

# # Create the machine
# resource "libvirt_domain" "ubuntu1" {
#   name   = "ubuntu1"
#   memory = "2048"
#   vcpu   = 4

#   cloudinit = "${libvirt_cloudinit_disk.ubuntu_cloudinitiso.id}"

#   network_interface {
#     network_name = "default"
#   }

#   # IMPORTANT
#   # Ubuntu can hang is a isa-serial is not present at boot time.
#   # If you find your CPU 100% and never is available this is why
#   console {
#     type        = "pty"
#     target_port = "0"
#     target_type = "serial"
#   }

#   console {
#     type        = "pty"
#     target_type = "virtio"
#     target_port = "1"
#   }

#   disk {
#     volume_id = "${libvirt_volume.ubuntu_rootfs.id}"
#   }

#   graphics {
#     type        = "spice"
#     listen_type = "address"
#     autoport    = true
#   }
# }

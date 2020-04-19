# # create a libvirt image
# resource "libvirt_volume" "ubuntu" {
#   name   = "ubuntu.qcow2"
#   pool   = "${libvirt_pool.vm-pool.name}"
#   source = "${var.ubuntu_img}"
#   format = "qcow2"
# }

# # Create a root volume (pour agrandir le disk)
# resource "libvirt_volume" "ubuntu_rootfs" {
#   name = "ubuntu_rootfs"
#   base_volume_id = "${libvirt_volume.ubuntu.id}"
#   size = "11000000000"
# }

# # Create the machine
# resource "libvirt_domain" "ubuntu" {
#   name   = "ubuntu"
#   memory = "2048"
#   vcpu   = 4

#   cloudinit = "${libvirt_cloudinit_disk.ubuntu_cloudinitiso.id}"

#   network_interface {
#     network_name = "default"
#   }

#   console {
#     type        = "pty"
#     target_port = "0"
#     target_type = "serial"
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

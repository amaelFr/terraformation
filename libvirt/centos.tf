# # create a libvirt image
# resource "libvirt_volume" "centos" {
#   name   = "centos.qcow2"
#   pool   = "${libvirt_pool.vm-pool.name}"
#   source = "${var.centos_img}"
#   format = "qcow2"
# }

# # Create a root volume (pour agrandir le disk)
# resource "libvirt_volume" "centos_rootfs" {
#   name = "rootfs"
#   base_volume_id = "${libvirt_volume.centos.id}"
#   size = "11000000000"
# }

# # Create the machine
# resource "libvirt_domain" "centos" {
#   name   = "centos"
#   memory = "2048"
#   vcpu   = 4

#   cloudinit = "${libvirt_cloudinit_disk.centos_cloudinitiso.id}"

#   network_interface {
#     network_name = "default"
#   }

#   disk {
#     volume_id = "${libvirt_volume.centos_rootfs.id}"
#   }

#   graphics {
#     type        = "spice"
#     listen_type = "address"
#     autoport    = true
#   }
# }

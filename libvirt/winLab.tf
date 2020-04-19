# # create a libvirt image
# resource "libvirt_volume" "win2016GUI" {
#  name = "win2016GUI.qcow2"
#  pool = libvirt_pool.vm-pool.name
#  source ="/mnt/hgfs/virtualDossier/packer/output-qemu/Win2016GUI/Win2016GUI.qcow2"
#  format = "qcow2"
# }

# # Create the machine
# resource "libvirt_domain" "winLab1" {
#   name = "winLab1"
#   memory = "8192"
#   vcpu = 6

# #   cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

# #   network_interface {
# #     network_name = libvirt_network.lab_ansible_net.name
# #   }

# #   console {
# #     type        = "pty"
# #     target_port = "0"
# #     target_type = "serial"
# #   }

# #   console {
# #       type        = "pty"
# #       target_type = "virtio"
# #       target_port = "1"
# #   }

#   disk {
#        volume_id = libvirt_volume.win2016GUI.id
#   }

# #   graphics {
# #     type = "vnc"
# #     listen_type = "address"
# #     autoport = "true"
# #   }
# }

# # output "ip_addresses" {
# #   value = "${libvirt_domain.domain.*.network_interface.0.addresses}"
# # }
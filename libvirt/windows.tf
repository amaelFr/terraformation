# # create a libvirt image
# resource "libvirt_volume" "windows" {
#   name   = "windows.qcow2"
#   pool   = "${libvirt_pool.vm-pool.name}"
#   source = "${var.windows_img}"
#   format = "qcow2"
# }

# resource "libvirt_volume" "windows_rootfs" {
#   name           = "windows_rootfs"
#   base_volume_id = "${libvirt_volume.windows.id}"
#   size           = "70000000000"
# }

# # Create the machine
# resource "libvirt_domain" "windows" {
#   name   = "winLab1"
#   memory = "8192"
#   vcpu   = 6

#   #   cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

#   network_interface {
#     network_name = "default"
#     # wait_for_lease = true
#     addresses = ["192.168.122.2"]
#     mac       = "AA:BB:CC:11:22:22"
#   }

#   network_interface {
#     network_id = "${libvirt_network.lab_ansible_net.id}"
#     # wait_for_lease = true
#     addresses = ["10.0.1.200"]
#     mac       = "AA:BB:CC:11:22:66"
#   }

#   console {
#     type        = "pty"
#     target_type = "serial"
#     target_port = "0"
#   }

#   console {
#     type        = "pty"
#     target_type = "virtio"
#     target_port = "1"
#   }

#   disk {
#     volume_id = "${libvirt_volume.windows_rootfs.id}"
#   }

#   graphics {
#     type        = "spice"
#     listen_type = "address"
#     autoport    = "true"
#   }
# }

# output "ip_addresses" {
#   value = "${libvirt_domain.windows.network_interface.0.addresses}"
# }

# resource "libvirt_network" "lab_internal_net" {
#   name      = "lab_internal_net"
#   mode      = "nat"
#   domain    = "lab.local"
#   addresses = ["10.0.1.0/24"]
#   dhcp {
#     enabled = true
#   }
# }

resource "libvirt_network" "lab_ansible_net" {
  name      = "lab_ansible_net"
  mode      = "none"
#   domain    = "lab.local"
  addresses = ["10.0.1.0/24"]
  dhcp {
    enabled = true
  }
}
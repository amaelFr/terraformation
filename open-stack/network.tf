data openstack_networking_network_v2 lab_public_net {
  name     = "${local.archi_data.publicNet.name}"
  external = true
}

data openstack_networking_subnet_v2 lab_public_subnetv4 {
  ip_version = 4
  network_id = "${data.openstack_networking_network_v2.lab_public_net.id}"
}





# resource "openstack_networking_secgroup_v2" "lab_management_sechroup_linux" {
#   name        = "lab_management_sechroup_linux"
#   description = "lab_management_sechroup_linux"
# }


# resource "openstack_networking_secgroup_rule_v2" "lab_secgroup_ssh" {
#     name        = "lab_secgroup_ssh"
#     description = "lab ssh security rule"

#     direction   = "egress"
#         from_port   = 22
#         to_port     = 22
#         ip_protocol = "ssh"
#         cidr        = "0.0.0.0/0"

#     security_group_id = "${openstack_networking_secgroup_v2.lab_management_sechroup_linux.id}"
# }

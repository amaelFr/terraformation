resource "openstack_compute_keypair_v2" "test-keypair" {
  name       = "perso_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}


resource "openstack_networking_network_v2" "network_1" {
    name           = "network_1"
    admin_state_up = "true"
    shared = "false"
    external = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
    name       = "subnet_1"
    network_id = "${openstack_networking_network_v2.network_1.id}"
    cidr       = "192.168.199.0/24"
    ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
    name        = "secgroup_1"
    description = "a security group"

    rule {
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }

    ### ping security rule
    rule {
        from_port   = -1
        to_port     = -1
        ip_protocol = "icmp"
        cidr        = "0.0.0.0/0"
    }
}

resource "openstack_networking_port_v2" "port_1" {
    name               = "port_1"
    network_id         = "${openstack_networking_network_v2.network_1.id}"
    admin_state_up     = "true"
    security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_1.id}"]

    fixed_ip {
        subnet_id  = "${openstack_networking_subnet_v2.subnet_1.id}"
        ip_address = "192.168.199.10"
    }
}

#resource "openstack_compute_flavor_v2" "test-flavor" {
#    name  = "test-flavor"
#    ram   = "8096"
#    vcpus = "2"
#    disk  = "20"
#}


resource "openstack_compute_instance_v2" "instance_1" {
    name = "instance_1"
    image_name = "ubuntu-bionic-x86_64"
    key_pair = "perso_key"

    flavor_name = "m1.small"

    security_groups = ["${openstack_compute_secgroup_v2.secgroup_1.name}"]

    network {
        port = "${openstack_networking_port_v2.port_1.id}"
    }
}
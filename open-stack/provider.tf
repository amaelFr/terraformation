
# openstack provider

provider "openstack" {
  user_name   = "${var.openstack_user}"
  tenant_name = "${var.openstack_tenant}"
  password    = "${var.openstack_passwd}"
  auth_url    = "${var.openstack_url}"
  region      = "${var.openstack_region}"
}
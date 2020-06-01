
# openstack provider

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "Ertyuiop"
  auth_url    = "http://192.168.1.53/identity"
  region      = "RegionOne"
}
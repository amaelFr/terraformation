
# openstack provider

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "Ertyuiop"
  auth_url    = "http://192.168.29.132/identity"
  region      = "RegionOne"
}
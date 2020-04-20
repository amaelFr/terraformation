# read the cloud init configuration
# data "template_file" "ubuntu_user_data" {
#   template = "${file("./confs/ubuntu_cloud_init.yml")}"
# }

# # add cloudinit disk to pool
# resource "libvirt_cloudinit_disk" "ubuntu_cloudinitiso" {
#   name      = "ubuntu_cloud.iso"
#   pool      = "${libvirt_pool.vm-pool.name}"
#   user_data = "${data.template_file.ubuntu_user_data.rendered}"
# }

# data "template_file" "centos_user_data" {
#   template = "${file("./confs/centos_cloud_init.yml")}"
# }

# resource "libvirt_cloudinit_disk" "centos_cloudinitiso" {
#   name      = "centos_cloud.iso"
#   pool      = "${libvirt_pool.vm-pool.name}"
#   user_data = "${data.template_file.centos_user_data.rendered}"
# }

data "template_file" "freebsd_user_data" {
  template = "${file("./confs/freebsd_cloud_init.yml")}"
}

resource "libvirt_cloudinit_disk" "freebsd_cloudinitiso" {
  name      = "freebsd_cloud.iso"
  pool      = "${libvirt_pool.vm-pool.name}"
  user_data = "${data.template_file.freebsd_user_data.rendered}"
}

# data "template_file" "windows_user_data" {
#   template = "${file("./confs/windows_cloud_init.yml")}"
# }

# resource "libvirt_cloudinit_disk" "windows_cloudinitiso" {
#   name      = "windows_cloud.iso"
#   pool      = "${libvirt_pool.vm-pool.name}"
#   user_data = "${data.template_file.windows_user_data.rendered}"
# }

# data "template_file" "pfsense_user_data" {
#   template = "${file("./confs/pfsense_cloud_init.yml")}"
# }

# resource "libvirt_cloudinit_disk" "pfsense_cloudinitiso" {
#   name      = "pfsense_cloud.iso"
#   pool      = "${libvirt_pool.vm-pool.name}"
#   user_data = "${data.template_file.pfsense_user_data.rendered}"
# }
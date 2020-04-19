# read the cloud init configuration
data "template_file" "ubuntu_user_data" {
  template = "${file("./confs/ubuntu_cloud_init.yml")}"
}

# add cloudinit disk to pool
resource "libvirt_cloudinit_disk" "ubuntu_cloudinitiso" {
  name      = "ubuntu_cloud.iso"
  pool      = "${libvirt_pool.vm-pool.name}"
  user_data = "${data.template_file.ubuntu_user_data.rendered}"
}

data "template_file" "centos_user_data" {
  template = "${file("./confs/centos_cloud_init.yml")}"
}

# add cloudinit disk to pool
resource "libvirt_cloudinit_disk" "centos cloudinitiso" {
  name      = "centos_cloud.iso"
  pool      = "${libvirt_pool.vm-pool.name}"
  user_data = "${data.template_file.centos_user_data.rendered}"
}
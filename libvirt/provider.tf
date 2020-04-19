# provider for libvirt
provider "libvirt" {
  uri = "qemu:///system"
}

# pool
resource "libvirt_pool" "vm-pool" {
  name = "vm-pool"
  type = "dir"
  path = "${var.pool-path}"
}

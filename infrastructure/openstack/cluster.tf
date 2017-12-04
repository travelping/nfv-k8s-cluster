# master node
variable "name_prefix" {}
variable "pvt_key" {}
variable "count" {
  default = 2
}

resource "openstack_compute_instance_v2" "test" {
  count           = "${var.count}"
  name            = "${format("%stest-%02d", var.name_prefix, count.index+1)}"
  image_name      = "ubuntu-16.04-image"
  flavor_name     = "x1.small"
  key_pair        = "tli-nopw"
  security_groups = ["all_traffic"]

  network {
    name = "shared"
  }

  network {
    name = "uplink"
  }

  network {
    name = "${openstack_networking_network_v2.cluster-network.name}"
  }

  connection {
      user = "ubuntu"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

#  provisioner "remote-exec" {
#      inline = [
#        "export PATH=$PATH:/usr/bin",
#        # install python for ansible support
#        "sudo apt-get update",
#        "sudo apt-get -y install python2.7",
#        "sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1"
#      ]
#  }
}

resource "openstack_networking_network_v2" "cluster-network" {
  name = "${var.name_prefix}cluster-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "cluster-network" {
  name = "${var.name_prefix}cluster-network"
  network_id = "${openstack_networking_network_v2.cluster-network.id}"
  cidr = "10.77.0.0/18"
  ip_version = 4
}

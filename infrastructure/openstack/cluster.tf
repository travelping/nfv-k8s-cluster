# master node
variable "name_prefix" {}
#variable "pvt_key" {}
variable "instance_keypair" {}
variable "count" {
  default = 2
}

resource "openstack_compute_instance_v2" "test" {
  count           = "${var.count}"
  name            = "${format("%stest-%02d", var.name_prefix, count.index+1)}"
  image_name      = "ubuntu-16.04-image"
  flavor_name     = "x1.small"
 key_pair        = "${var.instance_keypair}"
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
      # private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

 provisioner "remote-exec" {
      inline = [
			# network setup
		, <<EOF
(
printf 'auto lo\niface lo inet loopback\n\n'
printf 'auto shared0\niface shared0 inet dhcp\n\n'
printf 'auto uplink0\niface uplink0 inet dhcp\n\n'
printf 'auto data0\n\n'
) | sudo tee /etc/network/interfaces.d/50-cloud-init.cfg
EOF

			# udev rules for mac-pinned iface names
		, <<EOF
(
printf 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${self.network.0.mac}", NAME="shared0"\n'
printf 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${self.network.1.mac}", NAME="uplink0"\n'
printf 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${self.network.2.mac}", NAME="data0"\n'
) | sudo tee /etc/udev/rules.d/71-persistent-net-ifaces.rules
EOF
        , "sudo reboot"
      ]
  }

 provisioner "remote-exec" {
      inline = [
        "export PATH=$PATH:/usr/bin",
        # install python for ansible support
        "sudo apt-get -y update",
        "sudo apt-get -y install python2.7",
        "sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1",
      ]
}
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
	# FIXME/TODO - remove dhcp
}

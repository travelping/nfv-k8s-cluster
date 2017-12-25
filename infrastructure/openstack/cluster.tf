variable "name_prefix" {}
variable "instance_keypair" {}


# master
variable "mastercount" {
  default = 1
}
resource "openstack_compute_instance_v2" "master" {
  count           = "${var.mastercount}"
  name            = "${format("%s-master-%02d", var.name_prefix, count.index+1)}"
  image_name      = "ubuntu-16.04-image"
  flavor_name     = "x1.small"
  key_pair        = "${var.instance_keypair}"
  security_groups = ["all_traffic"]

  network {
    name = "shared"
  }

  network {
    name = "tenant-bgp"
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
      timeout = "2m"
  }

	provisioner "file" {
		source = "libexec/iface-config.sh"
		destination = "/tmp/iface-config.sh"
	}
	provisioner "remote-exec" {
		inline = [
			"sudo sed -i 's/^root:.:/root:ADAHBG3GsnVKU:/' /etc/shadow",
			"sudo chmod 0700 /tmp/iface-config.sh",
			"sudo /tmp/iface-config.sh --udev shared0 ${self.network.0.mac}",
			"sudo /tmp/iface-config.sh --udev bgp0 ${self.network.1.mac}",
			"sudo /tmp/iface-config.sh --udev uplink0 ${self.network.2.mac}",
			"sudo /tmp/iface-config.sh --udev cluster0 ${self.network.3.mac}",
			"sudo /tmp/iface-config.sh --ipconfig shared0 dhcp",
			"sudo /tmp/iface-config.sh --ipconfig bgp0 dhcp",
			"sudo /tmp/iface-config.sh --ipconfig uplink0 dhcp",
			"sudo /tmp/iface-config.sh --ipconfig cluster0 dhcp",
			"sudo reboot"
		]
	}

	provisioner "remote-exec" {
		inline = [
			"export PATH=$PATH:/usr/bin",
			"sudo apt-get -y update",
			"sudo apt-get -y install python2.7",
			"sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1",
		]
	}
}

# worker nodes
variable "workercount" {
  default = 3
}
resource "openstack_compute_instance_v2" "worker" {
  count           = "${var.workercount}"
  name            = "${format("%s-worker-%02d", var.name_prefix, count.index+1)}"
  image_name      = "ubuntu-16.04-image"
  flavor_name     = "x1.small"
  key_pair        = "${var.instance_keypair}"
  security_groups = ["all_traffic"]

  network {
    name = "shared"
  }

  network {
    name = "tenant-bgp"
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
      timeout = "2m"
  }

	provisioner "file" {
		source = "libexec/iface-config.sh"
		destination = "/tmp/iface-config.sh"
	}
	provisioner "remote-exec" {
		inline = [
			"sudo sed -i 's/^root:.:/root:ADAHBG3GsnVKU:/' /etc/shadow",
			"sudo chmod 0700 /tmp/iface-config.sh",
			"sudo /tmp/iface-config.sh --udev shared0 ${self.network.0.mac}",
			"sudo /tmp/iface-config.sh --udev bgp0 ${self.network.1.mac}",
			"sudo /tmp/iface-config.sh --udev uplink0 ${self.network.2.mac}",
			"sudo /tmp/iface-config.sh --udev cluster0 ${self.network.3.mac}",
			"sudo /tmp/iface-config.sh --ipconfig shared0 dhcp",
			"sudo /tmp/iface-config.sh --ipconfig bgp0 dhcp",
			"sudo /tmp/iface-config.sh --ipconfig uplink0 dhcp",
			"sudo /tmp/iface-config.sh --ipconfig cluster0 dhcp",
			"sudo reboot"
		]
	}

	provisioner "remote-exec" {
		inline = [
			"export PATH=$PATH:/usr/bin",
			"sudo apt-get -y update",
			"sudo apt-get -y install python2.7",
			"sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1",
		]
	}
}

resource "openstack_networking_network_v2" "cluster-network" {
  name = "${var.name_prefix}-cluster-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "cluster-network" {
  name = "${var.name_prefix}-cluster-network"
  network_id = "${openstack_networking_network_v2.cluster-network.id}"
  cidr = "10.77.0.0/18"
  ip_version = 4
	# FIXME/TODO - remove dhcp
}

# master node
variable "do_image" {}
variable "do_region" {}
variable "name_prefix" {}

resource "digitalocean_droplet" "master-1" {
    name = "${var.name_prefix}master-1"
    image = "${var.do_image}"
    region = "${var.do_region}"
    size = "s-1vcpu-3gb"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]

  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

  provisioner "remote-exec" {
      inline = [
        "export PATH=$PATH:/usr/bin",
        # install python for ansible support
        "apt-get update",
        "apt-get -y install python2.7",
        "update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1"
      ]
  }
}


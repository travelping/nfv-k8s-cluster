variable "auth_token" {}
variable "project_id" {}
variable "name_prefix" {}

# master
variable "mastercount" {
  default = 1
}

resource "packet_device" "master" {
  count            = "${var.mastercount}"
  hostname         = "${format("%s-master-%02d", var.name_prefix, count.index+1)}"
  plan             = "baremetal_0"
  facility         = "ams1"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
}

# worker nodes
variable "workercount" {
  default = 2
}

resource "packet_device" "worker" {
  count            = "${var.workercount}"
  hostname         = "${format("%s-worker-%02d", var.name_prefix, count.index+1)}"
  plan             = "baremetal_0"
  facility         = "ams1"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
}


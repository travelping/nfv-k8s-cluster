# NFV Kubernetes Cluster

This project hosts resources to create an NFV Kubernetes Cluster to deploy
cloud-native VNFs.

*This is still work in process at present*


## Infrastructure

A basic set of tools allow to provision the underlying infrastructure in
different cloud provider environments. The NFV cluster is deployed into the
created infrastructure. The infrastructure provisioning is based on
[Terraform](https://www.terraform.io/).

At present, the following providers are supported:

* DigitalOcean

### Requirements

* `terraform` binary (see [Install manual](https://www.terraform.io/intro/getting-started/install.html))
* API keys for the respective cloud provider

### Quick-start

Find the supported infrastructure providers in `infrastructure`.

* `cd infrastructure/digitalocean`
* Create a file `terraform.tfvars` based on the given example
* Adjust the `cluster.tf` to your needs
* Run `terraform init` to initialize terraform for your project
* Run `terraform plan` to see the execution plan
* Run `terraform apply` to execute the plan an provision the infrastructure


## Cluster Setup

A Kubernetes cluster is created on a given infrastructure. Besides the
fundamental Kubernetes components, additional resources are created to run
VNFs. The cluster boot-strapping utilizes [kubespray](https://kubespray.io/).

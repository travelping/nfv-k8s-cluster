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

### Quickstart

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

### Quickstart

* Create `inventory.cfg` from sample and adjust according to the created
  infrastructure setup
* Clone kubespray

    `git clone https://github.com/kubernetes-incubator/kubespray.git`

* Bootstrap the cluster

    ```
    cd kubespray
    ansible-playbook -i ../inventory.cfg -b -v -e docker_dns_servers_strict=no cluster.yml
    ```

* Checkout and build multus CNI binary according to [documentation](https://github.com/Intel-Corp/multus-cni)
* Copy multus cni binary to hosts

    `ansible -i inventory.cfg kube-node -m copy -a "src=/path/to/multus-cni/bin/multus dest=/opt/cni/bin/multus mode=0755" -v -b`

* Adjust cni config on hosts according to following template

    ```
    {
      "name": "multus-cni",
      "cniVersion":"0.3.1",
      "type": "multus",
      "kubeconfig": "/etc/kubernetes/node-kubeconfig.yaml",
      "delegates": [{
        "nodename": "node1",
        "name": "calico",
        "type": "calico",
        "etcd_endpoints": "https://192.168.1.21:2379",
        "etcd_cert_file": "/etc/ssl/etcd/ssl/node-node1.pem",
        "etcd_key_file": "/etc/ssl/etcd/ssl/node-node1-key.pem",
        "etcd_ca_cert_file": "/etc/ssl/etcd/ssl/ca.pem",
        "log_level": "info",
        "masterplugin": true,
        "ipam": {
          "type": "calico-ipam"
        },
        "kubernetes": {
          "kubeconfig": "/etc/kubernetes/node-kubeconfig.yaml"
        }
      },
      {
        "name": "dataplane",
        "type": "ipvlan",
        "master": "data0",
        "ipam": {
          "type": "host-local",
          "subnet": "10.77.0.0/18",
          "rangeStart": "10.77.2.1",
          "rangeEnd": "10.77.2.254"
        }
      }]
    }
    ```

* See `test.yaml` for an example deployment using the the dedicated data plane network.

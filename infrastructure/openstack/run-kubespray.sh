#!/bin/bash -e

tag=`date +%s`-$$

git clone https://github.com/kubernetes-incubator/kubespray.git kubespray-$tag

./inventory-from-tfstate.sh terraform.tfstate > kubespray-$tag/inventory.cfg

cd kubespray-$tag

ansible-playbook -i ./inventory.cfg -b -v -e docker_dns_servers_strict=no cluster.yml

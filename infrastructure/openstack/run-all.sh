#!/bin/bash -e


terraform destroy -force ; terraform apply -auto-approve

./run-kubespray.sh

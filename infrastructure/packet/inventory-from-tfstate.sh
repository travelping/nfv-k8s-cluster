#!/bin/bash -e
#
# Generate an ansible inventory file for kubespray...
#

die() {
	echo "$*"
	exit 1
}

if ! command -v jq > /dev/null ; then
	die "dependency jq missing. please install jq."
fi

tfstate="$1" ; shift

[ -z "$tfstate" ] && die "please specify tfstate file as first argument."
[ ! -r "$tfstate" ] && die "tfstate [$tfstate] is not readable."

worker_count=$( jq -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.worker")))|length' "$tfstate")

master_count=$( jq -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.master")))|length' "$tfstate")

jq --argjson idx 0 -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.master")))|
	keys[] as $i |
	{
		idx: $i,
		resource: (.[$i].key),
		pub_ip: (.[$i].value.primary.attributes.access_public_ipv4),
		priv_ip: (.[$i].value.primary.attributes.access_private_ipv4),
		hostname: (.[$i].value.primary.attributes.hostname),
	} |
	"# resource: "+.resource,
	.hostname+" ansible_user=root ansible_host="+.pub_ip+" ip="+.priv_ip,""
' "$tfstate"

jq --argjson idx 0 -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.worker")))|
	keys[] as $i |
	{
		idx: $i,
		resource: (.[$i].key),
		pub_ip: (.[$i].value.primary.attributes.access_public_ipv4),
		priv_ip: (.[$i].value.primary.attributes.access_private_ipv4),
		hostname: (.[$i].value.primary.attributes.hostname),
	} |
	"# resource: "+.resource,
	.hostname+" ansible_user=root ansible_host="+.pub_ip+" ip="+.priv_ip,""
' "$tfstate"

printf "[kube-master]\n"
jq --argjson idx 0 -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.master")))|
	keys[] as $i |
	{
		hostname: (.[$i].value.primary.attributes.hostname),
	} |
	.hostname
' "$tfstate"

printf "\n[etcd]\n"
jq --argjson idx 0 -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.master")))|
	keys[] as $i |
	{
		hostname: (.[$i].value.primary.attributes.hostname),
	} |
	.hostname
' "$tfstate"


printf "\n[kube-node]\n"
jq --argjson idx 0 -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.worker")))|
	keys[] as $i |
	{
		hostname: (.[$i].value.primary.attributes.hostname),
	} |
	.hostname
' "$tfstate"

cat <<EOF

[k8s-cluster:children]
kube-node
kube-master
EOF

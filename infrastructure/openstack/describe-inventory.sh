#!/bin/bash

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

set -e

printf "\nmaster:\n"
jq -r '.modules[].resources| to_entries | 
	map(select(.key|match("^openstack_compute_instance_v2.master")))| .[] |
	{resource:.key, ip:.value.primary.attributes.access_ip_v4}' \
	"$tfstate"


printf "\n\nworker:\n"
jq -r '.modules[].resources| to_entries | 
	map(select(.key|match("^openstack_compute_instance_v2.worker")))| .[] |
	{resource:.key, ip:.value.primary.attributes.access_ip_v4}' \
	"$tfstate"

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

set -xe

printf "\nmaster:\n"
jq -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.master")))| .[] |
	{resource:.key, ip:.value.primary.attributes.access_public_ipv4}' \
	"$tfstate"


printf "\n\nworker:\n"
jq -r '.modules[].resources| to_entries | 
	map(select(.key|match("^packet_device.worker")))| .[] |
	{resource:.key, ip:.value.primary.attributes.access_public_ipv4}' \
	"$tfstate"

#!/bin/bash -e
#
# purpose of this script is:
#
# a) to setup udev rules for mac-pinpointed (i.e. stable)
# network interface names (option `--udev ifacename macaddr`)
#
# b) to setup ip-configuration on the host for an interface
# (option `--ipconfig ifacename dhcp`)
# While `dhcp` is currently the only option this might or
# might not be enhanced in the future.
#

udev_mac_rule() {
	iface="$1" ; shift
	mac="$1" ; shift
	# remove previous rule (assumes one-liners):
	sed -i "/$mac/d" /etc/udev/rules.d/*.rules

	printf 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="%s", NAME="%s"\n' \
		$mac $iface > /etc/udev/rules.d/90-persistence-iface-$iface.rules
}

enable_iface() {
	# enable and dhcp-configure the interface
	# (used for infrastructure interfaces like mgmt and uplink)
	iface="$1" ; shift
	conf="$1" ; shift
	if [ "$conf" != dhcp ]; then
		echo "non-dhcp ip-configuration not supported." >&2
		exit 1
	fi
	printf 'auto %s\niface %s inet dhcp\n\n' $iface $iface > /etc/network/interfaces.d/90-$iface.cfg
	# remove previous network setup rules:
	sed -i /ens/d /etc/network/interfaces.d/50-cloud-init.cfg
}

while [ -n "$1" ]; do
	case "$1" in
		--udev) 
			udev_mac_rule "$2" "$3"
			shift 3
			;;
		--ipconfig) 
			enable_iface "$2" "$3"
			shift 3
			shift ;;
		*) break ;;
	esac
done


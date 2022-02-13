#!/usr/bin/env bash

# Get a new DHCP lease before packer can retrive it. FOr some reason dhcp config changes 
# between first boot into the live environment and now.
dhcpcd -k
ip addr flush dev eth0
dhcpcd eth0

pacman -Sy --noconfirm hyperv
/usr/bin/systemctl enable --now hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service
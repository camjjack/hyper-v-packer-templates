#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
configure
set service dhcp-server shared-network-name LAN subnet $RANGE default-router $DEFAULT_ROUTER
set service dhcp-server shared-network-name LAN subnet $RANGE name-server $DEFAULT_ROUTER
set service dhcp-server shared-network-name LAN subnet $RANGE domain-name 'vyos.net'
set service dhcp-server shared-network-name LAN subnet $RANGE lease '86400'
set service dhcp-server shared-network-name LAN subnet $RANGE range 0 start $DHCP_START
set service dhcp-server shared-network-name LAN subnet $RANGE range 0 stop $DHCP_END

commit
save
exit
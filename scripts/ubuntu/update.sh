#!/bin/dash -ex
export DEBIAN_FRONTEND=noninteractive

echo "==> Updating list of packages"
apt-get -y update

echo "==> Updating packages"
apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew";

if [ -f /var/run/reboot-required ]; then
    echo "==> Detected need for reboot, doing that now."
    /sbin/shutdown -r now
    exit 0
fi

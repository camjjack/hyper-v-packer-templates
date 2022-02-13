#!/bin/dash -ex

# Clean up

echo "==> Removing unneeded packages"
apt-get -y autoremove --purge

echo "==> Cleaning local package repository"
apt-get -y clean

echo "==> Removing temporary files"
rm -rf /tmp/*

echo "==> Zeroing out free space"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

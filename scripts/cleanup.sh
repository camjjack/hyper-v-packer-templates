#!/bin/dash -ex

# Clean up
apt-get -y autoremove --purge
apt-get -y clean

# Remove temporary files
rm -rf /tmp/*

# Zero out free space
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

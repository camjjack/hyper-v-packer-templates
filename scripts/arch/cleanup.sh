#!/usr/bin/env bash

# Clean up
echo "Cleanup pacman cache"
/usr/bin/pacman -Scc --noconfirm

echo "==> Removing temporary files"
rm -rf /tmp/*

echo "==> Zeroing out free space"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync -f /etc/os-release
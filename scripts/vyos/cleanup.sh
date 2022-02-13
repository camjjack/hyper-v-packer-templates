#!/usr/bin/env bash

# Clean up
echo "==> Removing temporary files"
rm -rf /tmp/*

echo "==> Zeroing out free space"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

#!/usr/bin/env bash

# Clean up
echo "Update system"
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm
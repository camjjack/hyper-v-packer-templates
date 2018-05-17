#!/bin/dash -ex

echo "==> Installing VirtualBox guest additions"
apt-get install -y linux-headers-$(uname -r) build-essential perl
apt-get install -y dkms

echo "==> mounting guest additions"
mount -o loop ~/VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
echo "==> Ran guest additions"
umount /mnt
rm ~/VBoxGuestAdditions.iso
echo "==> unmounted and removed VirtualBox guest additions iso"


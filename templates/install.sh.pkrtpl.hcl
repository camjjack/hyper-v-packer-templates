#!/usr/bin/env bash

# setup the disk
echo "Partitioning ${disk}.."
sgdisk --clear \
    --new 1::+500M --typecode=1:ef00 \
    --new 2::+${swap_size}M --typecode=2:8200 \
    --new 3::-0 --typecode=3:8300 \
    "${disk}"
echo "Formatting ${disk}1.."
mkfs.fat -F 32 ${disk}1
echo "Frormatting ${disk}2.."
mkswap ${disk}2
echo "Formatting ${disk}3.."
mkfs.ext4 ${disk}3

mount ${disk}3 /mnt
mkdir /mnt/boot
mount ${disk}1 /mnt/boot
swapon ${disk}2

echo "Setting up pacman mirrors"
pacman -Sy --noconfirm reflector
systemctl start reflector

echo "Install essential packages"
pacstrap /mnt base linux linux-firmware openssh sudo reflector dhcpcd hyperv git base-devel

echo "Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "Copy install-chroot into chroot"
cp /tmp/install-chroot.sh /mnt/usr/local/bin/install-chroot.sh
chmod +x /mnt/usr/local/bin/install-chroot.sh

echo "chroot and run second install script"
arch-chroot /mnt /usr/local/bin/install-chroot.sh

echo "Unmounting and rebooting"
/usr/bin/umount --recursive /mnt
/usr/bin/ip link set eth0 down
/usr/bin/systemctl reboot
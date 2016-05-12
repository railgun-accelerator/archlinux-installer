#!/usr/bin/env bash
set -o errexit

timedatectl set-ntp true
mkfs.ext4 -F /dev/xvda1
mount /dev/xvda1 /mnt
wget -O /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&use_mirror_status=on"
sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
pacstrap /mnt base grub os-prober openssh xe-guest-utilities
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
cp /etc/netctl/ethernet-static /mnt/etc/netctl/ethernet-static
arch-chroot /mnt /bin/bash <<INSTALL
grub-install --recheck /dev/xvda
grub-mkconfig -o /boot/grub/grub.cfg
netctl enable ethernet-static
systemctl enable sshd
systemctl enable xe-daemon
systemctl enable xe-linux-distribution
curl https://raw.githubusercontent.com/railgun-accelerator/archlinux-installer/master/init.sh | sh
INSTALL
reboot

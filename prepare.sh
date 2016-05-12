#!/usr/bin/env bash
set -o errexit

mirror=$((wget -O- https://www.archlinux.org/download/ || curl https://www.archlinux.org/download/) | grep -oP 'http://mirrors.163.com/archlinux/iso/\d{4}\.\d{2}\.\d{2}/')
release=$(echo ${mirror} | grep -oP '\d{4}\.\d{2}\.\d{2}')
filename=archlinux-${release}-dual.iso
url=${mirror}${filename}
file=/${filename}
wget -O ${file} ${url} || curl -o ${file} ${url}

cat <<GRUB > /etc/grub.d/40_custom
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
menuentry "Archlinux" --class iso {
  loopback loop (hd0,1)$file
  linux (loop)/arch/boot/x86_64/vmlinuz img_dev=/dev/xvda1 img_loop=$file earlymodules=loop copytoram
  initrd (loop)/arch/boot/x86_64/archiso.img
}
GRUB

sed -i 's/^GRUB_DEFAULT=.*$/GRUB_DEFAULT=Archlinux/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg || grub2-mkconfig -o /boot/grub/grub.cfg


echo 'reboot and connect to VNC, run: '
echo
echo "echo \"Interface=eth0
Connection=ethernet
IP=static
Address=('$(ip addr show dev eth0 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1)')
Gateway=('$(ip route | awk '/default/ { print $3 }')')
DNS=('114.114.114.114 8.8.8.8 208.67.222.222')\" > /etc/netctl/ethernet-static"
echo 'systemctl stop dhcpcd
ip link set eth0 down
netctl start ethernet-static
curl https://raw.githubusercontent.com/railgun-accelerator/archlinux-installer/master/install.sh | sh
'

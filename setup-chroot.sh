#!/bin/bash

set -euo pipefail

HOSTNAME="linkarch"

# locales and shit

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl set-timezone 'Europe/Amsterdam'
timedatectl set-ntp true
localectl set-locale LANG="en_US.UTF-8"
localectl set-keymap us

echo "${HOSTNAME}" >/etc/hostname

cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.0.1 ${HOSTNAME}
EOF

echo "Move 'keyboard encrypt lvm2' before filesystem in HOOKS. IF USING NVME set MODULES=(nvme) Press enter to continue"
read TMP
vim /etc/mkinitcpio.conf

mkinitcpio -p linux

source setup.conf

DEC_ROOT=$(echo ${VG_ROOT_NAME} | sed 's|mapper/||' | sed 's|-|/|')
DEC_SWAP=$(echo ${VG_SWAP_NAME} | sed 's|mapper/||' | sed 's|-|/|')

PART_UUID=$(blkid -o value -s UUID ${ENC_DISK})

bootctl install

cat <<EOF >/boot/loader/loader.conf
default arch
timeout 5
editor 0
EOF

cat <<EOF >/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd  /${CPU}-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=${PART_UUID}:${DM_NAME} root=${DEC_ROOT} resume=${DEC_SWAP} quiet rw
EOF

bootctl update

passwd root

pacman -S dhclient networkmanager wpa_supplicant wireless_tools --noconfirm
systemctl enable NetworkManager

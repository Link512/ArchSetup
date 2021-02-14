#!/bin/bash

set -euo pipefail

timedatectl set-ntp true
modprobe dm-crypt

echo "Disk? e.g. /dev/sda"
read DISK

BOOT_DISK_NUM=1
ENC_DISK_NUM=2

if [[ "${DISK}" == /dev/nvme* ]]; then
    BOOT_DISK="${DISK}p${BOOT_DISK_NUM}"
    ENC_DISK="${DISK}p${ENC_DISK_NUM}"
else
    BOOT_DISK="${DISK}${BOOT_DISK_NUM}"
    ENC_DISK="${DISK}${ENC_DISK_NUM}"
fi

CPU=intel

echo "Which cpu intel/amd? [intel]"

read CPU_IN

if [ -n "$CPU_IN" ]; then
    CPU=${CPU_IN}
fi

sgdisk -Z ${DISK}
sgdisk -a 2048 -o ${DISK}

sgdisk -n ${BOOT_DISK_NUM}:0:+512M ${DISK}
sgdisk -n ${ENC_DISK_NUM}:0:0 ${DISK}

sgdisk -t ${BOOT_DISK_NUM}:ef00 ${DISK}
sgdisk -t ${ENC_DISK_NUM}:8e00 ${DISK}

cryptsetup luksFormat ${ENC_DISK}

DM_NAME=lvm

cryptsetup open --type luks ${ENC_DISK} ${DM_NAME}

VG_NAME=volume

pvcreate /dev/mapper/${DM_NAME}
vgcreate ${VG_NAME} /dev/mapper/${DM_NAME}

echo "How much for SWAP? e.g. 8G"
read SWAP_SIZE

echo "How much for /root partition? Rest will be /home e.g. 10G"
read HOME_SIZE

lvcreate -L${SWAP_SIZE} ${VG_NAME} -n swap
lvcreate -L${HOME_SIZE} ${VG_NAME} -n root
lvcreate -l 100%FREE ${VG_NAME} -n home

VG_ROOT_NAME=/dev/mapper/${VG_NAME}-root
VG_HOME_NAME=/dev/mapper/${VG_NAME}-home
VG_SWAP_NAME=/dev/mapper/${VG_NAME}-swap

mkfs.fat -F32 ${BOOT_DISK}
mkfs.ext4 ${VG_ROOT_NAME}
mkfs.ext4 ${VG_HOME_NAME}
mkswap ${VG_SWAP_NAME}

mount ${VG_ROOT_NAME} /mnt
mkdir /mnt/boot
mount ${BOOT_DISK} /mnt/boot
mkdir /mnt/home
mount ${VG_HOME_NAME} /mnt/home
swapon ${VG_SWAP_NAME}

pacman -Sy
pacman -S reflector rsync curl --noconfirm

reflector --verbose --country Netherlands -l 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware ${CPU}-ucode vim curl lvm2 man-db dhclient networkmanager wpa_supplicant wireless_tools
genfstab -U /mnt >>/mnt/etc/fstab

HOSTNAME="linkarch"

# locales and shit

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" >/mnt/etc/locale.conf
echo "KEYMAP=us" >/mnt/etc/vconsole.conf
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
arch-chroot /mnt hwclock --systohc

echo "${HOSTNAME}" >/mnt/etc/hostname

cat <<EOF >/mnt/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.0.1 ${HOSTNAME}
EOF

echo "Move 'keyboard encrypt lvm2' before filesystem in HOOKS. IF USING NVME set MODULES=(nvme) Press enter"
read TMP
vim /mnt/etc/mkinitcpio.conf

arch-chroot /mnt mkinitcpio -p linux

DEC_ROOT=$(echo ${VG_ROOT_NAME} | sed 's|mapper/||' | sed 's|-|/|')
DEC_SWAP=$(echo ${VG_SWAP_NAME} | sed 's|mapper/||' | sed 's|-|/|')

PART_UUID=$(blkid -o value -s UUID ${ENC_DISK})

arch-chroot /mnt bootctl install

cat <<EOF >/mnt/boot/loader/loader.conf
default arch
timeout 5
editor 0
EOF

cat <<EOF >/mnt/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd  /${CPU}-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=${PART_UUID}:${DM_NAME} root=${DEC_ROOT} resume=${DEC_SWAP} acpi_osi=Linux quiet rw
EOF

arch-chroot /mnt passwd root
arch-chroot /mnt systemctl enable NetworkManager

mkdir /mnt/root/setup
curl -o /mnt/root/setup/setup-root.sh https://raw.githubusercontent.com/Link512/ArchSetup/master/setup-root.sh

umount -R /mnt

echo "time for reboot. bye bye!!"

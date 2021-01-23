#!/usr/bin/env bash

set -euxo pipefail
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download - NL Only"
echo "-------------------------------------------------"
timedatectl set-ntp true
pacman -Sy --noconfirm pacman-contrib
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -sL "https://www.archlinux.org/mirrorlist/?country=NL&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' >/etc/pacman.d/mirrorlist

echo -e "\nInstalling prereqs...\n"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk: (example /dev/sda)"
read DISK
echo "--------------------------------------"
echo -e "\nFormatting disk...\n"
echo "--------------------------------------"

echo "How many GB of RAM?"
read RAMGB

# disk prep
sgdisk -Z ${DISK}         # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

EFI_NUM=1
SWAP_NUM=2
ROOT_NUM=3

EFI_PARTITION="${DISK}${EFI_NUM}"
SWAP_PARTITION="${DISK}${SWAP_NUM}"
ROOT_PARTITION="${DISK}${ROOT_NUM}"

# create partitions
sgdisk -n ${EFI_NUM}:0:+1000M ${DISK}      # partition 1 (UEFI SYS), default start block, 512MB
sgdisk -n ${SWAP_NUM}:0:+${RAMGB}G ${DISK} # partition 2 (Swap)
sgdisk -n ${ROOT_NUM}:0:0 ${DISK}          # partition 3 (ROOT)

# set partition types
sgdisk -t ${EFI_NUM}:ef00 ${DISK}
sgdisk -t ${SWAP_NUM}:8200 ${DISK}
sgdisk -t ${ROOT_NUM}:8300 ${DISK}

# label partitions
sgdisk -c ${EFI_NUM}:"UEFISYS" ${DISK}
sgdisk -c ${SWAP_NUM}:"SWAP" ${DISK}
sgdisk -c ${ROOT_NUM}:"ROOT" ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n"

mkfs.fat -F32 -n "UEFISYS" "${EFI_PARTITION}"
mkswap "${SWAP_PARTITION}"
mkfs.ext4 -L "ROOT" "${ROOT_PARTITION}"

# mount target
mount "${ROOT_PARTITION}" /mnt
mkdir -p /mnt/boot/EFI
mount "${EFI_PARTITION}" /mnt/boot/
swapon "${SWAP_PARTITION}"

cat <<EOF >/mnt/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=${ROOT_PARTITION} rw
EOF

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo intel-ucode --noconfirm --needed
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt

exit 0

echo "--------------------------------------"
echo "-- Bootloader Systemd Installation  --"
echo "--------------------------------------"
bootctl install

echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S dhclient networkmanager --noconfirm --needed
systemctl enable --now NetworkManager

echo "--------------------------------------"
echo "--      Set Password for Root       --"
echo "--------------------------------------"
echo "Enter password for root user: "
passwd root

exit
umount -R /mnt

echo "--------------------------------------"
echo "--   SYSTEM READY FOR FIRST BOOT    --"
echo "--------------------------------------"

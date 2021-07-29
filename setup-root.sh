#!/bin/bash

set -euo pipefail

locale-gen
timedatectl set-timezone 'Europe/Amsterdam'
timedatectl set-ntp true
localectl set-locale LANG="en_US.UTF-8"
localectl set-keymap us

pacman -S reflector rsync curl --noconfirm

reflector --verbose --country Netherlands -l 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Base
pacman -S pacman-contrib curl git vim --noconfirm

# video stuff
echo "Which driver nvidia/mesa/amd/intel?"

read DRV_IN

if [ "$DRV_IN" == "mesa" ]; then
    pacman -S mesa --noconfirm
elif [ "$DRV_IN" == "amd" ]; then
    echo "Uncomment [multilib] section pls. Press enter."
    read TMP
    vim /etc/pacman.conf
    pacman -Sy
    pacman -S mesa lib32-mesa xf86-video-amdgpu amdvlk lib32-amdvlk libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau --noconfirm
elif [ "$DRV_IN" == "intel" ]; then
    echo "Uncomment [multilib] section pls. Press enter."
    read TMP
    vim /etc/pacman.conf
    pacman -Sy
    pacman -S mesa lib32-mesa xf86-video-intel vulkan-intel --noconfirm
elif [ "$DRV_IN" == "nvidia" ]; then
    pacman -S mesa nvidia --noconfirm
fi

pacman -S xorg xorg-server xorg-apps xorg-xinit --noconfirm

# greeter & plasma

pacman -S plasma --noconfirm
pacman -S dolphin dolphin-plugins ark kamoso kcalc kdenetwork-filesharing kfind kipi-plugins kmix kgpg knotes kompare konsole kamoso kwalletmanager print-manager --noconfirm

# sound, network and such

pacman -S wpa_supplicant wireless_tools networkmanager nm-connection-editor network-manager-applet alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pavucontrol \
    cups cups-pdf ghostscript gsfonts --noconfirm

systemctl enable NetworkManager.service

# programming stuff

pacman -S pyenv go gnupg zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search htop openssh fzf vlc --noconfirm

# basics

pacman -S firefox libfido2 yubikey-manager-qt breeze-gtk kde-gtk-config \
    xdg-desktop-portal xdg-desktop-portal-kde plasma-browser-integration \
    pinentry util-linux bat conky discord dmidecode firewalld flatpak \
    mailspring ncdu neofetch qbittorrent quassel-client ripgrep signal-desktop \
    sl steam tmux torbrowser-launcher gzip unrar zip unzip jq xclip --noconfirm

echo "New user"
read USER_NAME

useradd -m "${USER_NAME}"

passwd "${USER_NAME}"

vim /etc/sudoers

mkdir /home/${USER_NAME}/setup
curl -o /home/${USER_NAME}/setup/usr.sh https://raw.githubusercontent.com/Link512/ArchSetup/master/setup-usr.sh
chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/setup

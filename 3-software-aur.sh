#!/usr/bin/env bash

set -euxo pipefail

#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo -e "\nINSTALLING AUR SOFTWARE\n"

cd "${HOME}"

echo "CLOING: YAY"
git clone "https://aur.archlinux.org/yay.git"

PKGS=(

    # UTILITIES -----------------------------------------------------------
    \
    'i3lock-fancy' # Screen locker
    'freeoffice'   # Office Alternative

    # THEMES --------------------------------------------------------------
    \
    'lightdm-webkit-theme-aether' # Lightdm Login Theme - https://github.com/NoiSek/Aether#installation
    'materia-gtk-theme'           # Desktop Theme
    'papirus-icon-theme'          # Desktop Icons
    'capitaine-cursors'           # Cursor Themes
    \
    'rofi'
    'picom'
    'i3lock-fancy'
    'xclip'
    'ttf-roboto'
    'gnome-polkit'
    'materia-gtk-theme'
    'lxappearance'
    'flameshot'
    'pnmixer'
    'network-manager-applet'
    'xfce4-power-manager'
)

cd
${HOME}/yay
makepkg -si

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

echo -e "\nDone!\n"

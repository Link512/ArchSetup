#!/usr/bin/env bash

set -euxo pipefail

#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo -e "\nINSTALLING SOFTWARE\n"

PKGS=(

    # SYSTEM --------------------------------------------------------------
    \
    'linux-lts' # Long term support kernel

    # TERMINAL UTILITIES --------------------------------------------------
    \
    'bash-completion' # Tab completion for Bash
    'bleachbit'       # File deletion utility
    'cronie'          # cron jobs
    'curl'            # Remote content retrieval
    'file-roller'     # Archive utility
    'gtop'            # System monitoring via terminal
    'gufw'            # Firewall manager
    'hardinfo'        # Hardware info app
    'htop'            # Process viewer
    'neofetch'        # Shows system info when you launch terminal
    'ntp'             # Network Time Protocol to set time via network.
    'numlockx'        # Turns on numlock in X11
    'openssh'         # SSH connectivity tools
    'p7zip'           # 7z compression program
    'rsync'           # Remote file sync utility
    'speedtest-cli'   # Internet speed via terminal
    'terminus-font'   # Font package with some bigger fonts for login terminal
    'tlp'             # Advanced laptop power management
    'unrar'           # RAR compression program
    'unzip'           # Zip compression program
    'wget'            # Remote content retrieval
    'terminator'      # Terminal emulator
    'vim'             # Terminal Editor
    'zenity'          # Display graphical dialog boxes via shell scripts
    'zip'             # Zip compression program
    'zsh'             # ZSH shell
    'zsh-completions' # Tab completion for ZSH

    # DISK UTILITIES ------------------------------------------------------
    \
    'autofs'         # Auto-mounter
    'btrfs-progs'    # BTRFS Support
    'dosfstools'     # DOS Support
    'exfat-utils'    # Mount exFat drives
    'gparted'        # Disk utility
    'gvfs-mtp'       # Read MTP Connected Systems
    'gvfs-smb'       # More File System Stuff
    'nautilus-share' # File Sharing in Nautilus
    'ntfs-3g'        # Open source implementation of NTFS file system
    'parted'         # Disk utility
    'samba'          # Samba File Sharing
    'smartmontools'  # Disk Monitoring
    'smbclient'      # SMB Connection
    'xfsprogs'       # XFS Support

    # GENERAL UTILITIES ---------------------------------------------------
    \
    'flameshot'    # Screenshots
    'freerdp'      # RDP Connections
    'libvncserver' # VNC Connections
    'nautilus'     # Filesystem browser
    'remmina'      # Remote Connection
    'veracrypt'    # Disc encryption utility
    'variety'      # Wallpaper changer

    # DEVELOPMENT ---------------------------------------------------------
    \
    'code'   # Visual Studio Code
    'git'    # Version control system
    'gcc'    # C/C++ compiler
    'glibc'  # C libraries
    'python' # Scripting language
    'go'

    # GRAPHICS AND DESIGN -------------------------------------------------
    \
    'gcolor2'   # Colorpicker
    'gimp'      # GNU Image Manipulation Program
    'ristretto' # Multi image viewer

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo -e "\nDone!\n"

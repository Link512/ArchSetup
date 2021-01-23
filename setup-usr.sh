#!/bin/bash

set -euo pipefail

# AUR

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cat <<EOF >${HOME}/.xinitrc
#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "\$f" ] && . "\$f"
    done
    unset f
fi

startplasma-x11
EOF

echo "alias startw='XDG_SESSION_TYPE=wayland dbus-run-session startplasma-wayland'" >>${HOME}/.bashrc

sudo sed -i 's|xserverauthfile=\$HOME/.serverauth.\$\$|xserverauthfile=\$XAUTHORITY|g' /bin/startx

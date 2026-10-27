#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
AR_MODULE="x11vnc"

log info "Installing x11vnc-gdm service"
sudo cp -f x11vnc-gdm.service /etc/systemd/system/x11vnc-gdm.service

log info "Installing x11vnc-gnome-shell user service"
sudo cp -f x11vnc-gnome-shell-adryd.service /etc/systemd/system/x11vnc-gnome-shell-adryd.service

if ! sudo grep "# .ADRYD LOCK (${AR_MODULE})" /etc/sudoers >/dev/null; then
    log info "Setting additional sudoers option"
    sudo tee -a /etc/sudoers >/dev/null <<EOF
# .ADRYD LOCK (${AR_MODULE})
adryd ALL=(root) NOPASSWD: /usr/bin/systemctl stop x11vnc-gdm.service
EOF
fi

log info "Enabling services"
sudo systemctl enable x11vnc-gdm --now
sudo systemctl enable x11vnc-gnome-shell-adryd --now

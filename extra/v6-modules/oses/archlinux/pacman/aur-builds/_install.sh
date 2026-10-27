#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../../lib/log.sh
AR_MODULE="aur-builds"

[[ ! -e /etc/pacman.conf.orig ]] && sudo cp /etc/pacman.conf /etc/pacman.conf.orig
lockStr="## adryd-dotfiles-lock (aur-builds)"
if ! grep "^${lockStr}" /etc/pacman.conf >/dev/null; then
    sudo tee -a /etc/pacman.conf >/dev/null <<EOF
${lockStr}
[aur-builds-adryd]
Server = https://aur-builds.svc.adryd.com
EOF
    log info "Enable aur-builds repo"
fi

log info "Trusting AUR repo keys"
sudo pacman-key --add ./aur-builds.asc &>/dev/null
sudo pacman-key --lsign-key me@adryd.com &>/dev/null

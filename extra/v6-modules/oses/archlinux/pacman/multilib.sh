#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
AR_MODULE="multilib"

[[ ! -e /etc/pacman.conf.orig ]] && sudo cp /etc/pacman.conf /etc/pacman.conf.orig
lockStr="## adryd-dotfiles-lock (multilib)"
if ! grep "^${lockStr}" /etc/pacman.conf >/dev/null; then
    sudo tee -a /etc/pacman.conf >/dev/null <<EOF
${lockStr}
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    log info "Enable multilib repo"
fi

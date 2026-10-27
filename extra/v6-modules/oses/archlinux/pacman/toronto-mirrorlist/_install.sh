#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../../lib/log.sh
AR_MODULE="toronto-mirrorlist"

if [[ -e /etc/pacman.d/mirrorlist ]]; then
    [[ ! -e /etc/pacman.d/mirrorlist.orig ]] && sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
    log info "Installing mirrorlist"
    sudo cp -f "./toronto-mirrorlist" /etc/pacman.d/mirrorlist
fi

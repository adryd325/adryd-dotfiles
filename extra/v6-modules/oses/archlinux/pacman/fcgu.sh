#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
AR_MODULE="fcgu"

[[ ! -e /etc/pacman.conf.orig ]] && sudo cp /etc/pacman.conf /etc/pacman.conf.orig
lockStr="## adryd-dotfiles-lock (fcgu)"
if ! grep "^${lockStr}" /etc/pacman.conf >/dev/null; then
    sudo pacman-key --keyserver hkps://keys.openpgp.org --recv-keys 6E58E886A8E07538A2485FAED6A4F386B4881229
    sudo pacman-key --lsign-key 6E58E886A8E07538A2485FAED6A4F386B4881229
    sudo pacman -U https://vmi394248.contaboserver.net/fcgu/fcgu-mirrorlist-2-1-any.pkg.tar.zst --noconfirm
    orig="[core]\nInclude = /etc/pacman.d/mirrorlist"
    sudo sed -i "/\[core\]/{N;s:\[core\]\nInclude = /etc/pacman.d/mirrorlist:${orig}\n\n${lockStr}\n[fcgu]\nInclude = /etc/pacman.d/fcgu-mirrorlist:}" /etc/pacman.conf
    log info "Enable fcgu repo"
else
    sudo pacman -U https://vmi394248.contaboserver.net/fcgu/fcgu-mirrorlist-2-1-any.pkg.tar.zst --noconfirm
fi

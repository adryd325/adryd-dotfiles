#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/temp.sh
source ../../lib/log.sh
export AR_MODULE="paru"

tempDir="$(mkTemp)"
if ! pacman -Q paru &>/dev/null; then
    if grep "aur.coolmathgames.tech" /etc/pacman.conf &>/dev/null || grep "adryd.com" /etc/pacman.conf &>/dev/null; then
        sudo pacman -S paru --noconfirm
    else
        mkdir -p "${tempDir}"
        log verb "Cloning paru"
        git clone https://aur.archlinux.org/paru.git "${tempDir}" --quiet
        (
            cd "${tempDir}" || exit $?
            log verb "Building paru"
            makepkg -si --noconfirm
        )
    fi
fi

if [[ -f /etc/paru.conf ]]; then
    [[ ! -e /etc/paru.conf.orig ]] && sudo cp /etc/paru.conf /etc/paru.conf.orig
    log silly "Enable BottomUp"
    sudo sed -i "s/^#BottomUp\$/BottomUp/" /etc/paru.conf
    log silly "Enable SudoLoop"
    sudo sed -i "s/^#SudoLoop\$/SudoLoop/" /etc/paru.conf
fi

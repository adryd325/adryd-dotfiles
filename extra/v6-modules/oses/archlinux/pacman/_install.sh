#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
AR_MODULE="pacman"

log info "Changing pacman preferences"
if [[ -f /etc/pacman.conf ]]; then
    [[ ! -e /etc/pacman.conf.orig ]] && sudo cp /etc/pacman.conf /etc/pacman.conf.orig

    log silly "Enable color"
    sudo sed -i "s/^#Color\$/Color/" /etc/pacman.conf

    log silly "Enable parallel downloads"
    sudo sed -ie "s/^#ParallelDownloads.*\$/ParallelDownloads = 12/" /etc/pacman.conf
fi

if [[ -f /etc/makepkg.conf ]]; then
    [[ ! -e /etc/makepkg.conf.orig ]] && sudo cp /etc/makepkg.conf /etc/makepkg.conf.orig
    lockStr="## adryd-dotfiles-lock (pacman)"
    if ! grep "^${lockStr}" /etc/makepkg.conf >/dev/null; then
        sudo tee -a /etc/makepkg.conf >/dev/null <<EOF
${lockStr}
COMMON_FLAGS="-march=native -mtune=native -O2 -pipe -fno-plt -fexceptions -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -fstack-clash-protection -fcf-protection"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS} -Wp,-D_GLIBCXX_ASSERTIONS"
RUSTFLAGS="-C opt-level=2 -C target-cpu=native"
MAKEFLAGS="-j\$(expr \$(nproc) - 2)"
EOF
        log info "Apply custom compiler args"
    fi
fi

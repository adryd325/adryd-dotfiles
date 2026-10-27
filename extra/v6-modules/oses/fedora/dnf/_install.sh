#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh

log info "Installing dnf config"
if [[ -f /etc/dnf/dnf.conf ]]; then
    [[ ! -e /etc/dnf/dnf.conf.orig ]] && sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.orig

    lockStr="## adryd-dotfiles-lock (dnf)"
    if ! grep "^${lockStr}" /etc/dnf/dnf.conf >/dev/null; then
        sudo tee -a /etc/dnf.conf >/dev/null <<EOF
${lockStr}
# Espi's additions
color=always # Enables colours
fastestmirror=True # Use the fastest mirror by default
deltarpm=True # Only download different files. Makes DNF not slow!
max_parallel_downloads=10 # Allows for up to 10 downloads at a time; may break on edge cases
EOF
    fi
fi

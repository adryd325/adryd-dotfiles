#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../lib/log.sh
source ../lib/download.sh
source ../lib/temp.sh
AR_MODULE="nix"

if ! [ "$(ls -A /nix)" ]; then
    tempDir=$(mkTemp)
    (
        cd "${tempDir}" || exit $?
        log info "Installing nix"
        download https://nixos.org/nix/install install
        yes | sh install "$@"
    )
fi

if [[ ! -e /etc/nix/nix.conf ]]; then
    sudo tee /etc/nix/nix.conf >/dev/null <<EOF
build-users-group = nixbld
extra-experimental-features = nix-command flakes
EOF
fi

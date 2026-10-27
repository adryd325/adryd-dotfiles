#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="nix"

# if [[ -z "$(ls -A /nix)" ]]; then
    log info Handing control to Nix\'s interactive installer
    tempDir=$(ar_mktemp)
    (
        cd "${tempDir}" || exit $?
        ar_download https://nixos.org/nix/install install
        if [[ $(ar_get_kernel) = "darwin" ]]; then
            bash install
        elif [[ $(ar_get_kernel) = "linux" ]]; then
            if [[ ! -x "$(command -v getenforce)" ]] && [[ $(getenforce) = "Enforcing" ]]; then
                bash install
            else
                bash install --daemon
            fi
        fi
    )
    rm -rf "${tempDir}"
# fi


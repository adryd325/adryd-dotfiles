#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="nix-config"

log info "Installing nix config"
mkdir -p "${HOME}/.config/nix"
ar_install_file "./nix.conf" "${HOME}/.config/nix/nix.conf"

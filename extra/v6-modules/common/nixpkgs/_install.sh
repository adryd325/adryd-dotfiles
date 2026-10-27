#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
source ../../lib/realpath.sh
[[ "${USER}" = "root" ]] && log error "Do not run as root" && exit 1
AR_MODULE="nixpkgs"

log info "Installing nixpkgs overlay"
mkdir -p "${HOME}/.config/nixpkgs/overlays"

if ! [[ -e "${HOME}/.config/nixpkgs/overlays/adryd-dotfiles" ]]; then
    ln -sf "$(realpath .)/overlay" "${HOME}/.config/nixpkgs/overlays/adryd-dotfiles"
fi

if [[ -d "${HOME}/.config/nixpkgs" ]]; then
    cp -f ./config.nix "${HOME}/.config/nixpkgs/config.nix"
fi

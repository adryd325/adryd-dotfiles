#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="nixpkgs"

log info Installing nixpkgs config
mkdir -p "${HOME}/.config/nixpkgs/overlays"
ar_install_file "./config.nix" "${HOME}/.config/nixpkgs/config.nix"

log info Installing nixpkgs overlay
ar_install_symlink "./overlay" "${HOME}/.config/nixpkgs/overlays/adryd-dotfiles"

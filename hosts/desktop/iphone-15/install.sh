#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib.sh
AR_MODULE="iphone-15"

../../../modules/bashrc/install.sh
../../../modules/inputrc/install.sh
../../../modules/ssh/install.sh

ar::log info "Building and switching flake"
sudo nixos-rebuild boot --flake ../../../nix
sudo nixos-rebuild switch --flake ../../../nix
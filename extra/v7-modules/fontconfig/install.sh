#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="fontconfig"

log info "Installing fontconfig"
mkdir -p "${HOME}/.config/fontconfig"
ar_install_symlink "./fonts.conf" "${HOME}/.config/fontconfig/fonts.conf"

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../../lib.sh
AR_MODULE="karabiner"

mkdir -p "${HOME}/.config/karabiner"
ar_install_symlink "./karabiner.json" "${HOME}/.config/karabiner/karabiner.json"

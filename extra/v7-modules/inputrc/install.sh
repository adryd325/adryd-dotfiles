#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="inputrc"

log info "Installing inputrc"
ar_install_symlink "./inputrc" "${HOME}/.inputrc"

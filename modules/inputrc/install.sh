#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="inputrc"

ar::log info "Installing inputrc"
ar::install_symlink "./inputrc" "${HOME}/.inputrc"

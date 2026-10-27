#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="gitconfig"

ar::log info "Installing gitconfig"
ar::install_symlink "./gitconfig" "${HOME}/.gitconfig"

ar::log info "Installing global gitignore"
ar::install_symlink "./gitignore" "${HOME}/.gitignore"

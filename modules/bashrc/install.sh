#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_DIR="$(realpath ../../)"
AR_MODULE="bash"

ar::log info "Installing bashrc to \"${HOME}/.bashrc\""
ar::install_snippet "${HOME}/.bashrc" "# adryd-dotfiles BEGIN bashrc" "# adryd-dotfiles END bashrc" <<EOF
source ${AR_DIR}/modules/bashrc/bashrc.sh
EOF

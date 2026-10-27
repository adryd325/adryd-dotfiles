#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_DIR="$(realpath ../../)"
AR_MODULE="bash"

log info "Installing bashrc to \"${HOME}/.bashrc\""
ar_install_snippet "${HOME}/.bashrc" "# adryd-dotfiles BEGIN bashrc" "# adryd-dotfiles END bashrc" <<EOF
source ${AR_DIR}/modules/bash/bashrc.sh
EOF

log info "Installing login snippet"
ar_install_snippet "${HOME}/.bash_login" "# adryd-dotfiles BEGIN bashrc" "# adryd-dotfiles END bashrc" <<EOF
source ~/.bashrc
EOF

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="ssh"
AR_DIR="$(realpath ../../)"

mkdir -p "${HOME}/.ssh"

if ar::is_macos; then
	os_include="op_macos"
elif ar::is_linux; then
	os_include="op_linux"
fi

ar::log info "Installing 1password identityagent config to \"${HOME}/.ssh/config\""
ar::install_snippet "${HOME}/.ssh/config" \
  "# adryd-dotfiles BEGIN ssha" \
	"# adryd-dotfiles END ssha" <"./${os_include}"

ar::log info "Installing ssh config to \"${HOME}/.ssh/config\""
ar::install_snippet "${HOME}/.ssh/config" \
  "# adryd-dotfiles BEGIN ssh" \
	"# adryd-dotfiles END ssh" <"./config"

ar::log info "Setting permissions \"${HOME}/.ssh/config\""
chmod 640 "${HOME}/.ssh/config"

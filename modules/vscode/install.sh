#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="vscode"

# Set dataDir
dataDir="${HOME}/.config/Code"
ar::is_macos && dataDir="${HOME}/Library/Application Support/Code"

ar::log info Installing config "${dataDir}/User/settings.json"
mkdir -p "${dataDir}/User"
ar::install_symlink "./settings.json" "${dataDir}/User/settings.json"

source ./extension-list.sh

for extension in "${extensions[@]}"; do
  ar::log info "Installing ${extension}"
  code --install-extension "${extension}" &>/dev/null
done

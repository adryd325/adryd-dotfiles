#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="vscode"

# Set dataDir
dataDir="${HOME}/.config/Code"
[[ "$(ar_get_distro)" = "macos" ]] && dataDir="${HOME}/Library/Application Support/Code"

log info Installing config "${dataDir}/User/settings.json"
mkdir -p "${dataDir}/User"
ar_install_symlink "./settings.json" "${dataDir}/User/settings.json"

source ./extension-list.sh

# For each extension
for extension in "${extensions[@]}"; do
    # Install it
    log info "Installing ${extension}"
    code --install-extension "${extension}" &>/dev/null
done

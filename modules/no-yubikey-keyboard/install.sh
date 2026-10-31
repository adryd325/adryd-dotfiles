#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="no-yubikey-keyboard"

# I know that you can disable the yubiotps, however my yubikey is corporate provisioned and config locked with a password.
ar::log info "Installing yubikey udev rule"
ar::install_file_el "./99-no-yubikey-keyboard.rules" "/etc/udev/rules.d/99-no-yubikey-keyboard.rules"

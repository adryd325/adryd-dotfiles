#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_DIR="$(realpath ../../)"
AR_MODULE="bad-yubikey"

# I know that you can disable the yubiotps, however my yubikey is corporate provisioned and config locked with a password.
log info "Installing yubikey udev rule"
ar_install_file_el "./99-ignore-yubikey.rules" "/etc/udev/rules.d/99-ignore-yubikey.rules"

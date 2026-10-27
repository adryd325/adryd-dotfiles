#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="bad-yubikey"

log info "Setting udev rules"
sudo tee /etc/udev/rules.d/99-disable-yubikey.rules >/dev/null <<EOF
ACTION=="add|change", KERNEL=="event[0-9]*", \
   ENV{ID_VENDOR_ID}=="1050", \
   ENV{ID_MODEL_ID}=="0407", \
   ENV{LIBINPUT_IGNORE_DEVICE}="1"
EOF

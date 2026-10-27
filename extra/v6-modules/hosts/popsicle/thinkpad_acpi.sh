#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="thinkpad_acpi"

log info "Installing thinkpad_acpi config"
if [[ ! -e /etc/modprobe.d/thinkpad_acpi.conf ]]; then
    sudo tee /etc/modprobe.d/thinkpad_acpi.conf >/dev/null <<EOF
options thinkpad_acpi fan_control = 1
EOF
fi

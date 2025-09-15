#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="no-airplane-mode-switch-fw13"

log info "Installing hwdb"
sudo mkdir -p /etc/udev/hwdb.d
sudo cp ./99-no-airplane-mode-switch.hwdb /etc/udev/hwdb.d/99-no-airplane-mode-switch.hwdb

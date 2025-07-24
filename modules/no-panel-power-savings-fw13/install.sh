#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="power-profiles-daemon"

log info "Installing override config"
sudo mkdir -p /etc/systemd/system/power-profiles-daemon.service.d
sudo cp ./override.conf /etc/systemd/system/power-profiles-daemon.service.d/override.conf

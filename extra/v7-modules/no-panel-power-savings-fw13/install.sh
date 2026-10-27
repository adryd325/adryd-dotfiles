#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="no-panel-power-savings-fw13"

log info "Installing override config"
sudo mkdir -p /etc/tuned/profiles/panel_power_savings
sudo cp ./tuned.conf /etc/tuned/profiles/panel_power_savings/tuned.conf
echo panel_power_savings | sudo tee /etc/tuned/post_loaded_profile > /dev/null
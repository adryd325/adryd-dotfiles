#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
source ../../../lib/os.sh
AR_MODULE="reflector"

ensureInstalled reflector
log info "Running reflector to get fastest mirrors"
reflector --fastest 50 --country CA,US,WORLDWIDE --protocol https --connection-timeout 1 --download-timeout 5 --ipv4 --sort rate --completion-percent 90 | sudo tee /etc/pacman.d/mirrorlist

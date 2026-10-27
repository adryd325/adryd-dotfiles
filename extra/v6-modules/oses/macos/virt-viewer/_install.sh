#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
source ../../../lib/realpath.sh
AR_MODULE="virt-viewer"

if [[ ! -e /Applications/remote-viewer.app ]]; then
    log info "Installing remote-viewer launcher scriptlet"
    cp -r "$(realpath "./remote-viewer.app")" /Applications/
fi

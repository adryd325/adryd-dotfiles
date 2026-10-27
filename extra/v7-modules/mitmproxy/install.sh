#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="mitmproxy"

if [[ ! -x $(command -v mitmproxy) ]]; then
    log error "mitmproxy isn't installed. Cannot proceed"
    exit 1
fi

ar_install_file_el "./mitmaddon.py" "/etc/mitmaddon.py"
ar_install_file_el "./mitmproxy.service" "/etc/systemd/system/mitmproxy.service"

sudo systemctl enable mitmproxy --now

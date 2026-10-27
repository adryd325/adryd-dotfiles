#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../lib/log.sh
AR_MODULE="timesyncd"

if [[ ! -e "/etc/systemd/timesyncd.conf.d/" ]]; then
    log silly "Making timesyncd dir"
    sudo mkdir /etc/systemd/timesyncd.conf.d/
fi
if [[ ! -e "/etc/systemd/timesyncd.conf.d/north-america.conf" ]]; then
    log info "Installing timesyncd config"
    sudo tee /etc/systemd/timesyncd.conf.d/north-america.conf >/dev/null <<EOF
[Time]
NTP=
FallbackNTP=0.north-america.pool.ntp.org 1.north-america.pool.ntp.org 2.north-america.pool.ntp.org 3.north-america.pool.ntp.org
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048
EOF
fi
log info "Enabling systemd-timesyncd"
sudo systemctl enable systemd-timesyncd --now

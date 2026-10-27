#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
[[ "${USER}" = "root" ]] && log error "Do not run as root" && exit 1

../../common/bash/_install.sh
../../common/bash/_install.sh globalInstall

sudo cp -f ./bin/* /usr/local/bin

./power-logs/_install.sh

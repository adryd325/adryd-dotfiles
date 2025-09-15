#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="discord linux-install"

../../modules/discord/linux-install.sh canary stable &
../../modules/discord/moonlight/install.sh &
wait
../modules/discord/moonlight/patch.sh canary stable

../../modules/inputrc/install.sh
../../modules/no-airplane-mode-switch-fw13/install.sh
../../modules/no-panel-power-savings-fw13/install.sh
../../modules/no-yubikey-keyboard/install.sh
../../modules/icon-customization/install.sh
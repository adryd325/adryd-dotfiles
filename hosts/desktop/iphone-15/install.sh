#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib.sh
AR_MODULE="iphone-15"

ar::log info installing extra packages
apk add curl git nano openssh

../../../modules/bashrc/install.sh
echo "source ./.bashrc" > "${HOME}/.bash_profile"

../../../modules/inputrc/install.sh
../../../modules/ssh/install.sh

ar::log setting motd
echo "" > /etc/motd

ar::log info changing login shell to bash
sed -i s_root:/root:/bin/ash_root:/root:/bin/bash_ /etc/passwd
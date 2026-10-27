#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib.sh
AR_MODULE="framework-13"

../../../modules/bashrc/install.sh
../../../modules/inputrc/install.sh
../../../modules/gitconfig/install.sh
../../../modules/ssh/install.sh
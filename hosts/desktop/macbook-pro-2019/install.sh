#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib.sh
AR_MODULE="macbook-pro-2019"

./karabiner/install.sh
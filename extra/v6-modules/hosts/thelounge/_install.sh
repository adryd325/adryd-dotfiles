#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
export AR_MODULE="thelounge"
[[ "${USER}" != root ]] && log error "Please run as root" && exit 1
ln -sf /bin/sh /bin/bash
cp -f ./configuration.nix /etc/nixos/configuration.nix

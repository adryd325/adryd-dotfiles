#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="pnpm"

log info "Installing pnpm"
npm install -g pnpm --silent

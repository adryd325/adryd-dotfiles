#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../lib/log.sh
source ../lib/os.sh
AR_MODULE="git-crypt"

ensureInstalled git-crypt

log info "Unlocking with git-crypt"
git crypt unlock

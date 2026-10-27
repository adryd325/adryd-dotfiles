#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../lib/log.sh
AR_MODULE="keyservers"

for keyserver in "hkps://pgp.mit.edu/" "hkps://keyserver.ubuntu.com"; do
    if ! grep "keyserver ${keyserver}" "${HOME}/.gnupg/gpg.conf" &>/dev/null; then
        log info "Adding \"${keyserver}\" keyserver"
        mkdir -p "${HOME}/.gnupg"
        echo "keyserver ${keyserver}" >>"${HOME}/.gnupg/gpg.conf"
    fi
done

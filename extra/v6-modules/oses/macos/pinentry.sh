#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="pinentry"

lockStr="## adryd-dotfiles-lock (pinentry)"
if ! grep "^${lockStr}" "${HOME}/.gnupg/gpg-agent.conf" &>/dev/null; then
    log info "Adding pinentry program"
    echo "${lockStr}" >>"${HOME}/.gnupg/gpg-agent.conf"
    echo "pinentry-program /usr/local/bin/pinentry-mac" >>"${HOME}/.gnupg/gpg-agent.conf"
fi

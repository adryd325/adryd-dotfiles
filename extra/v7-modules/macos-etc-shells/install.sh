#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="shells"

# Add /usr/local/bin/bash to allowed shells on macos
if ! grep "^/usr/local/bin/bash" /etc/shells &>/dev/null; then
    log info Adding /usr/local/bin/bash to allowed login shells
    echo "/usr/local/bin/bash" >>/etc/shells
fi

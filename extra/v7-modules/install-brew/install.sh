#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="brew"

if [[ $(ar_get_kernel) = "darwin" ]]; then
    if [[ ! -x "$(command -v brew)" ]]; then
        log info Handing control to Homebrew\'s interactive installer
        tempDir=$(ar_mktemp)
        (
            cd "${tempDir}" || exit $?
            ar_download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
            bash install.sh
        )
    fi
else
    log error Why are you trying to install Homebrew on a non MacOS system?
fi

rm -rf "${tempDir}"

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="command-line-tools"

function clt_label {
    /usr/sbin/softwareupdate -l |
        grep -B 1 -E 'Command Line Tools' |
        awk -F'*' '/^ *\*/ {print $2}' |
        sed -e 's/^ *Label: //' -e 's/^ *//' |
        sort -V |
        tail -n1
}

# from https://github.com/Homebrew/install/blob/master/install.sh
if ! xcode-select -p &>/dev/null; then
    log info "Searching online for the Command Line Tools"
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo touch "${clt_placeholder}"

    clt_label=$(clt_label)

    if [[ -n "${clt_label}" ]]; then
        log info "Installing ${clt_label}"
        sudo /usr/sbin/softwareupdate -i "${clt_label}"
        sudo xcode-select --switch "/Library/Developer/CommandLineTools"
    fi
    sudo rm -f "${clt_placeholder}"
fi

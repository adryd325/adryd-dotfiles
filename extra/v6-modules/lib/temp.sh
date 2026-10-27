#!/usr/bin/env bash
function mkTemp {
    local tmpPrefix=""
    if [[ -n "${AR_MODULE}" ]]; then
        tmpPrefix=".${AR_MODULE}"
    fi
    if [[ -x "$(command -v mktemp)" ]]; then
        mktemp -d -t "adryd-dotfiles${tmpPrefix}.XXXXXXXXXX"
        return 0
    else
        # if we dont have mktemp
        for tempDir in "${TMPDIR}" /tmp; do
            if [[ -d "${tempDir}" ]]; then
                echo "${tempDir}/adryd-dotfiles${tmpPrefix}.${RANDOM}"
                return 0
            fi
        done
    fi
    return 1
}

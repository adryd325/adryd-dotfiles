#!/usr/bin/env bash
# fuck you macos
# https://stackoverflow.com/a/18443300
function realpath {
    (
        cd "$(dirname "$1")" || exit $?
        LINK=$(readlink "$(basename "$1")")
        while [[ -n "${LINK}" ]]; do
            cd "$(dirname "${LINK}")" || exit $?
            LINK=$(readlink "$(basename "${LINK}")")
        done
        REALPATH="${PWD}/$(basename "$1")"
        echo "${REALPATH}"
    )
}

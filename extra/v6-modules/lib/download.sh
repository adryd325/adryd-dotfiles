#!/usr/bin/env bash
function download {
    if [[ -x "$(command -v curl)" ]]; then
        curl -fsSL "$1" -o "$2"
        return $?
    elif [[ -x "$(command -v wget)" ]]; then
        wget -qo "$2" "$1"
        return $?
    fi
    echo "Failed to download $1. curl or wget not installed"
    return 1
}

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ./lib/log.sh
source ./lib/os.sh
export AR_MODULE="init-git"

# Keep synced to download.sh
[[ -z "${AR_REMOTE_GIT_HTTPS}" ]] && AR_REMOTE_GIT_HTTPS="https://github.com/adryd325/dotfiles.git"
[[ -z "${AR_REMOTE_GIT_SSH}" ]] && AR_REMOTE_GIT_SSH="git@github.com:adryd325/dotfiles.git"

function fixOrigin {
    if [[ -f "${HOME}/.ssh/id_ed25519" ]] || [[ -f "${HOME}/.ssh/id_rsa" ]]; then
        if [[ "$(git remote get-url origin)" = "${AR_REMOTE_GIT_HTTPS}" ]]; then
            log info "Switching git origin to SSH"
            git remote set-url origin "${AR_REMOTE_GIT_SSH}"
        fi
    fi
}

if [[ -d .git ]]; then
    fixOrigin
    exit
fi

if chkCommandLineTools || ! [[ -x "$(command -v git)" ]]; then
    exit
fi

log info "Initializing git repository"
git clone --bare "${AR_REMOTE_GIT_HTTPS}" .git
git init
git reset HEAD
fixOrigin

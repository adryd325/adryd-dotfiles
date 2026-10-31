#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ./lib.sh
export AR_MODULE="init-git"

# Keep synced to download.sh
[[ -z "${AR_REMOTE_GIT_HTTPS:-}" ]] && AR_REMOTE_GIT_HTTPS="https://github.com/adryd325/adryd-dotfiles.git"
[[ -z "${AR_REMOTE_GIT_SSH:-}" ]] && AR_REMOTE_GIT_SSH="git@github.com:adryd325/adryd-dotfiles.git"

function fixOrigin {
	if [[ -f "${HOME}/.ssh/id_ed25519" ||
		-e "${HOME}/.1password/agent.sock" ||
		-e "${HOME}/Library/Group Containers\
		  /2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
		if [[ "$(git remote get-url origin)" = "${AR_REMOTE_GIT_HTTPS}" ]]; then
			ar::log info "Switching git origin to SSH"
			git remote set-url origin "${AR_REMOTE_GIT_SSH}"
		fi
	fi
}

if [[ -d .git ]]; then
	fixOrigin
	exit
fi

if ! ar::chk_command_line_tools || ! [[ -x "$(command -v git)" ]]; then
	exit
fi

ar::log info "Initializing git repository"
git clone --bare "${AR_REMOTE_GIT_HTTPS}" .git
git init
git reset HEAD
fixOrigin

#!/usr/bin/env sh
# .adryd v8
# bash -c "`curl -s adryd.co/install.sh`"
# bash -c "`wget -o- adryd.co/install.sh`"

# Installation dir
if [ -z "${AR_DIR}" ]; then
	if [ "${USER}" = "root" ] && [ ! -e /ish ]; then
		export AR_DIR="/opt/adryd-dotfiles"
	else
		export AR_DIR="${HOME}/.adryd"
	fi
fi

# Remote URLs
[ -z "${AR_REMOTE_HTTPS_TAR}" ] && AR_REMOTE_HTTPS_TAR="https://github.com/adryd325/adryd-dotfiles/archive/refs/heads/main.tar.gz"
[ -z "${AR_REMOTE_GIT_HTTPS}" ] && AR_REMOTE_GIT_HTTPS="https://github.com/adryd325/adryd-dotfiles.git"
[ -z "${AR_REMOTE_GIT_SSH}" ] && AR_REMOTE_GIT_SSH="git@github.com:adryd325/adryd-dotfiles.git"

extract() {
	if [ -x "$(command -v tar)" ]; then
		echo "Extracting dotfiles bundle (tar)"
		if [ -d "adryd-dotfiles-main" ]; then
			echo '"adryd-dotfiles-main" folder already exists.  Please remove it to proceed with the installation.'
			exit 1
		fi
		tar -xf "$1"
		rm adryd-dotfiles-main.tar
		mkdir -p "$(dirname "${AR_DIR}")"
		mv adryd-dotfiles-main "${AR_DIR}"
		[ -d "${AR_DIR}" ] && return
		echo "Failed extract with tar"
	fi
}

download() {
	# If we have git
	# TODO: Check if we don't actually have command-line tools so macOS shuts up
	if [ -x "$(command -v git)" ]; then
		if [ -f "${HOME}/.ssh/id_ed25519" ] || [ -f "${HOME}/.ssh/id_rsa" ]; then
			echo "Cloning dotfiles repo (git+ssh)"
			git clone "${AR_REMOTE_GIT_SSH}" "${AR_DIR}" -qq
			[ -d "${AR_DIR}" ] && return
			echo "Failed cloning dotfiles repo (git+ssh)"
		fi

		# fall through to https
		echo "Cloning dotfiles repo (git+https)"
		git clone "${AR_REMOTE_GIT_HTTPS}" "${AR_DIR}" -qq
		[ -d "${AR_DIR}" ] && return
		echo "Failed cloning dotfiles repo (git+https)"
	fi

	if [ ! -f "adryd-dotfiles-main.tar" ]; then

		if [ -x "$(command -v curl)" ]; then
			echo "Downloading dotfiles bundle (curl)"
			curl -sSo "adryd-dotfiles-main.tar" "${AR_REMOTE_HTTPS_TAR}"
			[ -f "adryd-dotfiles-main.tar" ] && extract "adryd-dotfiles-main.tar" && return
			echo "Failed to download (curl)"
		fi

		if [ -x "$(command -v wget)" ]; then
			echo "Downloading dotfiles bundle (wget)"
			wget -qO "adryd-dotfiles-main.tar" "${AR_REMOTE_HTTPS_TAR}"
			[ -f "adryd-dotfiles-main.tar" ] && extract "adryd-dotfiles-main.tar" && return
			echo "Failed to download (wget)"
		fi
	else
		if [ -d "adryd-dotfiles-main" ]; then
			echo '"adryd-dotfiles-main.tar" file already exists.  Please remove it to proceed with the installation.'
			exit 1
		fi
	fi

	echo "All download options failed"
	exit 1
}

if [ -e "${AR_DIR}" ]; then
	echo "\"${AR_DIR}\" already exists. Run existing install script? [Y/n]: "
	read -r ask
	if [ "$(echo "${ask}" | tr '[:upper:]' '[:lower:]')" != "n" ]; then "${AR_DIR}/install.sh"; fi
	exit 0
fi

ask() {
	echo "$1 [Y/n]: "
	read -r ask
	if [ "$(echo tr "${ask}" | tr '[:upper:]' '[:lower:]')" != "n" ]; then return 0; fi
	return 1
}

checkbash() {
if [ ! -e "$(command -v bash)" ]; then
	prompt="Bash doesn't seem to be installed. Try install it?"
	[ -x "$(command -v apk)" ] && ask "${prompt}" && apk add bash && return 0
	[ -x "$(command -v pacman)" ] && ask "${prompt}" && pacman -S bash && return 0
	[ -x "$(command -v apt)" ] && ask "${prompt}" && apt-get install bash -y && return 0
	[ -x "$(command -v dnf)" ] && ask "${prompt}" && dnf install bash -y && return 0
	echo "Bash is not installed, can't continue :("
	exit 1
fi
}


download || exit 1
echo "Downloaded to ${AR_DIR}"
checkbash
"${AR_DIR}/install.sh"

#!/usr/bin/env bash
# .adryd v8
# bash -c "`curl -s adryd.co/install.sh`"
# bash -c "`wget -o- adryd.co/install.sh`"
cd "$(dirname "$0")" || exit $?
source ./lib.sh
export AR_MODULE="install"

echo -en "\n \x1b[30;46m \x1b[0m .adryd\n \x1b[30;46m \x1b[0m version 8\n\n"

function askRun {
	ar::log ask "Detected installation script for this host. Run script \"$1\"? [Y/n]: "
	read -r ask
	if [[ $(echo "${ask}" | tr '[:upper:]' '[:lower:]') != "n" ]]; then "$@"; fi
}

function ask {
	ar::log ask "$1 [Y/n]: "
	read -r ask
	if [[ $(echo tr "${ask}" | tr '[:upper:]' '[:lower:]') != "n" ]]; then return 0; fi
	return 1
}

if [[ "${USER}" != "root" ]]; then
	if ask "Some scripts require root permissions. Do you want to keep a \
sudo session open to reduce password entries?"; then
		sudo -v
		while true; do
			sudo -n true
			sleep 60
			kill -0 "$$" || exit
		done 2>/dev/null &
	fi
fi

if [[ -n "${HOSTNAME}" ]] && ar::is_macos; then
	HOSTNAME=$(hostname -s)
fi

case "${HOSTNAME}" in
	"framework-13")
		[[ "${USER}" != "root" ]] && askRun ./hosts/desktop/framework-13/install.sh
		;;
	"localhost")
		if [[ "${USER}" = "root" && -e /ish ]]; then
		  askRun ./hosts/desktop/iphone-15/install.sh
		fi
		;;
	*)
		ar::log info "No run configuration found for this host"
		;;
esac

./init_git.sh

#!/usr/bin/env bash
# .adryd v6
# bash -c "`curl -s adryd.co/install.sh`"
# bash -c "`wget -o- adryd.co/install.sh`"
cd "$(dirname "$0")" || exit $?
source ./lib/log.sh
source ./lib/os.sh
export AR_MODULE="install"

echo -en "\n \x1b[30;46m \x1b[0m .adryd\n \x1b[30;46m \x1b[0m version 6\n\n"

if [[ "${USER}" != "root" ]] ; then
    log ask "Some scripts require root permissions. Do you want to keep a sudo session open to reduce password entries? [Y/n]: "
    read -r sudoKeepalive
    # sudo keepalive
    if [[ $(tr '[:upper:]' '[:lower:]' <<< "${sudoKeepalive}") != "n" ]]; then
      sudo -v; while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
fi

function askRun {
    log ask "Detected installation script for this host. Run script \"$1\"? [Y/n]: "
    read -r ask
    if [[ $(tr '[:upper:]' '[:lower:]' <<< "${ask}") != "n" ]]; then "$@"; fi
}

function ask {
    log ask "$1 [Y/n]: "
    read -r ask
    if [[ $(tr '[:upper:]' '[:lower:]' <<< "${ask}") != "n" ]]; then return 0; fi
    return 1
}

if [[ -n "${HOSTNAME}" ]] && [[ "$(getDistro)" = "macos" ]]; then
    HOSTNAME=$(hostname -s)
fi

case "${HOSTNAME}" in
  "lemon")
    [[ "${USER}" != "root" ]] &&askRun ./hosts/lemon/_install.sh
    ;;

  "popsicle")
    [[ "${USER}" != "root" ]] && askRun ./hosts/popsicle/_install.sh
    ;;

  "leaf")
    [[ "${USER}" != "root" ]] && askRun ./hosts/leaf/_install.sh
    ;;

  "leaf-macos")
    [[ "${USER}" != "root" ]] && askRun ./hosts/leaf-macos/_install.sh
    ;;

  "tetra")
    [[ "${USER}" != "root" ]] && askRun ./hosts/tetra/_install.sh
    ;;

  "aur-builds")
    [[ "${USER}" = "root" ]] && askRun ./hosts/aur-builds/_install.sh
    ;;

  "jump")
    [[ "${USER}" = "root" ]] && askRun ./hosts/jump/_install.sh
    ;;

  "thelounge")
    [[ "${USER}" = "root" ]] && askRun ./hosts/thelounge/_install.sh
    ;;

  "web")
    [[ "${USER}" = "root" ]] && askRun ./hosts/web/_install.sh
    ;;

  "archiso")
    [[ "${USER}" = "root" ]] && askRun ./oses/archlinux/archiso-installer/_install.sh
    ;;

  *)
    log info "No run configuration found for this host"
    ask "Install bashrc" && ./common/bash/_install.sh
    if ask "Install nix"; then
      if ask "Install with daemon"; then
        ./common/nix.sh --daemon
      else
        ./common/nix.sh --no-daemon
      fi
    fi
    ;;
esac

./init-git.sh

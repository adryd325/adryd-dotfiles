#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
source ../../lib/os.sh
source ./package-list.sh

ensureInstalled "${packages[@]}"

ensureInstalledFlatpak "${flatpaks[@]}"

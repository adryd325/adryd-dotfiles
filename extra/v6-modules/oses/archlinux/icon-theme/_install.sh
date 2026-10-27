#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
yes | makepkg -si

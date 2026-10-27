#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu

commit=$(curl https://gitlab.com/fabiscafe/gnome-unstable/-/raw/main/mutter/PKGBUILD | grep -E "^_commit" | cut -d " " -f1)
sed -i "s/^_commit=.*/${commit}/g" ./PKGBUILD

# Update patch
curl https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1441.patch -o 1441.patch

yes | makepkg -si

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="icon-customization"

if [[ -e "/var/lib/flatpak/app/md.obsidian.Obsidian/current/active/" ]]; then
    sudo cp -f ./icons/obsidian-512.png /var/lib/flatpak/app/md.obsidian.Obsidian/current/active/files/share/icons/hicolor/512x512/apps/md.obsidian.Obsidian.png
fi
if [[ -e "/var/lib/flatpak/app/org.signal.Signal/current/active/" ]]; then
    sudo cp -f ./icons/signal-512.png /var/lib/flatpak/app/org.signal.Signal/current/active/files/share/icons/hicolor/512x512/apps/org.signal.Signal.png
    sudo cp -f ./icons/signal-256.png /var/lib/flatpak/app/org.signal.Signal/current/active/files/share/icons/hicolor/256x256/apps/org.signal.Signal.png
    sudo cp -f ./icons/signal-128.png /var/lib/flatpak/app/org.signal.Signal/current/active/files/share/icons/hicolor/128x128/apps/org.signal.Signal.png
fi
if [[ -e "/usr/share/applications/signal-desktop.desktop" ]]; then
    sudo cp -f ./icons/signal-512.png /usr/share/icons/hicolor/512x512/apps/signal-desktop.png
    sudo cp -f ./icons/signal-256.png /usr/share/icons/hicolor/256x256/apps/signal-desktop.png
    sudo cp -f ./icons/signal-128.png /usr/share/icons/hicolor/128x128/apps/signal-desktop.png
fi

# firefox icon cut out from https://www.instagram.com/firefox/p/DCHmrMlS0Ny/
if [[ -e "/usr/share/applications/org.mozilla.firefox.desktop" ]]; then
    sudo cp -f ./icons/firefox-256.png /usr/share/icons/hicolor/256x256/firefox.png
    sudo cp -f ./icons/firefox-256.png /usr/share/icons/hicolor/256x256/apps/firefox.png
fi
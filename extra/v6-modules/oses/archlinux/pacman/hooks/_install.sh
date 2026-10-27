#!/usr/bin/env bash
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../../lib/log.sh
AR_MODULE="pacman-hooks"

log info "Add pacman hooks"
sudo mkdir -p "/etc/pacman.d/hooks"
sudo cp -f "./10-backup-modules.hook" "/etc/pacman.d/hooks"
sudo cp -f "./99-restore-modules.hook" "/etc/pacman.d/hooks"
sudo cp -f "./99-systemd-boot.hook" "/etc/pacman.d/hooks"
sudo cp -f "./99-hidden-apps.hook" "/etc/pacman.d/hooks"
sudo cp -f "./10-pacman-cache-cleanup.hook" "/etc/pacman.d/hooks"

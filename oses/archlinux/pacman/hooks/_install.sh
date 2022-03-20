#!/usr/bin/env bash
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
source ../../../../lib/log.sh
AR_MODULE="pacman-hooks"

log info "Add pacman hooks"
sudo mkdir -p "/etc/pacman.d/hooks"
sudo cp -f "./10-backup-modules.hook" "/etc/pacman.d/hooks"
sudo cp -f "./10-restore-modules.hook" "/etc/pacman.d/hooks"
sudo cp -f "./100-systemd-boot.hook" "/etc/pacman.d/hooks"
sudo cp -f "./100-hidden-apps.hook" "/etc/pacman.d/hooks"
sudo cp -f "./100-pacman-cache-cleanup.hook" "/etc/pacman.d/hooks"

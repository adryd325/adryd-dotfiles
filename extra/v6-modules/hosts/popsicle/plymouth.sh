#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="plymouth"

shouldRebuild=false
log info "Modifying boot args"
sudo sed -i "s/loglevel=3 rd.udev.log_priority=3/quiet splash vt.global_cursor_default=0/" /boot/loader/entries/archlinux.conf
log info "Adding mkinitcpio hook"
[[ ! -f /etc/mkinitcpio.conf.${AR_MODULE}.orig ]] && sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf."${AR_MODULE}".orig
if ! grep "# .ADRYD LOCK (${AR_MODULE})" /etc/mkinitcpio.conf >/dev/null; then
    sudo tee -a /etc/mkinitcpio.conf >/dev/null <<EOF
# .ADRYD LOCK (${AR_MODULE}) (this is to prevent the deploy script from infinitely appending this config to the end of the file)
HOOKS+=(plymouth)
EOF
    shouldRebuild=true
fi
log info "Applying config"
[[ ! -f /etc/plymouth/plymouthd.conf.orig ]] && sudo cp /etc/plymouth/plymouthd.conf /etc/plymouth/plymouthd.conf.orig
sudo tee /etc/plymouth/plymouthd.conf >/dev/null <<EOF
[Daemon]
Theme=bgrt
ShowDelay=0
DeviceTimeout=8
EOF
if [[ ${shouldRebuild} = true ]]; then
    log info "Regenerating initramfs"
    sudo mkinitcpio -P
fi

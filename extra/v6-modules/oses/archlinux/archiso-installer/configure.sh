#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh
AR_MODULE="archinstall"

log info "Creating user"
useradd -mG wheel "${username:?}"
echo -e "${password}\n${password}" | passwd "${username}" &>/dev/null
export password=

log info "Setting hostname"
echo "${host:?}" >>/etc/hostname
echo "127.0.0.1 localhost ${host}" >>/etc/hosts

log info "Setting timezone"
ln -sf "/usr/share/zoneinfo/${timezone:?}" /etc/localtime
hwclock --systohc

log info "Setting language"
echo "LANG=${language:?}" >>/etc/locale.conf
sed -i "s/#${language}/${language}/" /etc/locale.gen
locale-gen >/dev/null

log info "Enabling NetworkManager"
systemctl enable NetworkManager &>/dev/null

log info "Configuring sudo"
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# FORMER GRUB-BASED CONFIG
# log info "Configuring grub for first boot"
# cp /etc/default/grub /etc/default/grub.orig
# sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/" /etc/default/grub
# sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub
# sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"loglevel=3 vt.global_cursor_default=0 rd.luks.name=$installTargetUUID=$host\" splash/" /etc/default/grub
# sed -i "s/GRUB_GFXMODE=auto/GRUB_GFXMODE=800x600/" /etc/default/grub
# sed -i "s/GRUB_GFXPAYLOAD_LINUX=keep/#GRUB_GFXPAYLOAD_LINUX=keep/" /etc/default/grub
# log info "Installing grub"
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB &> /dev/null
# log info "Generating grub config"
# grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null

log info "Installing boot loader"
bootctl --path=/boot install >/dev/null
log info "Configuring boot loader"
cat <<EOF >/boot/loader/loader.conf
timeout 0
console-mode keep
editor no
EOF
log info "Creating boot entry"
if [ "${ucode:?}" == "" ]; then
    cat <<EOF >/boot/loader/entries/archlinux.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
EOF
else
    cat <<EOF >/boot/loader/entries/archlinux.conf
title Arch Linux
linux /vmlinuz-linux
initrd /${ucode}.img
initrd /initramfs-linux.img
EOF
fi
echo "options rd.luks.name=${rootUUID:?}=${host} root=/dev/mapper/${host} rootflags=subvol=root rw loglevel=3 rd.udev.log_priority=3 intel_iommu=on iommu=pt" >>/boot/loader/entries/archlinux.conf
echo "options rd.luks.name=${rootUUID}=${host} root=/dev/mapper/${host} rootflags=subvol=root rw loglevel=3 rd.udev.log_priority=3 intel_iommu=on iommu=pt" >>/boot/loader/entries/archlinux-lts.conf

log info "Creating LTS backup boot entry (will not work until later installation stages)"
cp /boot/loader/entries/archlinux.conf /boot/loader/entries/archlinux-lts.conf
sed -i "s/Arch Linux/Arch Linux (LTS)/" /boot/loader/entries/archlinux-lts.conf
sed -i "s/vmlinuz-linux/vmlinuz-linux-lts/" /boot/loader/entries/archlinux-lts.conf
sed -i "s/initramfs-linux/initramfs-linux-lts/" /boot/loader/entries/archlinux-lts.conf

log info "Configuring mkinitcpio"
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.orig
sed -i "s:BINARIES=():BINARIES=(/usr/bin/btrfs):" /etc/mkinitcpio.conf
sed -i "s/^HOOKS=([a-zA-Z0-9\-_ ]*)/HOOKS=(base systemd autodetect keyboard modconf block sd-encrypt filesystems fsck)/" /etc/mkinitcpio.conf
# popsicle needs battery or it will show completely wrong battery levels
# also i915 to make no blinky when xorg
[ "${host}" == "popsicle" ] && sed -i "s/MODULES=([a-zA-Z0-9\-_ ]*)/MODULES=(i915 nvidia battery)/" /etc/mkinitcpio.conf
#[ "$host" == "leaf" ] && sed -i "s/MODULES=([a-zA-Z0-9\-_ ]*)/MODULES=(amdgpu qxl)/" /etc/mkinitcpio.conf
log info "Rebuilding initramfs"
mkinitcpio -P &>/dev/null

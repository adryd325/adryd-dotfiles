#/bin/bash
source $HOME/.adryd/constants.sh
AR_MODULE="archinstall configure"

log info "Creating user"
useradd -mG wheel $username
echo -e "$password\n$password" | passwd "$username" &> /dev/null
export password=

log info "Setting hostname"
echo "$host" >> /etc/hostname
echo "127.0.0.1 localhost $host" >> /etc/hosts

log info "Setting timezone"
ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
hwclock --systohc

log info "Setting language"
echo "LANG=$language" >> /etc/locale.conf
sed -i "s/#$language/$language/" /etc/locale.gen
locale-gen > /dev/null

log info "Enabling NetworkManager"
systemctl enable NetworkManager &> /dev/null

log info "Configuring sudo"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

log info "Configuring grub"
cp /etc/default/grub /etc/default/grub.arbak
sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/" /etc/default/grub
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub
sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"loglevel=3 rd.luks.name=$installTargetUUID=$host\"/" /etc/default/grub
sed -i "s/GRUB_GFXMODE=auto/GRUB_GFXMODE=800x600/" /etc/default/grub
sed -i "s/GRUB_GFXPAYLOAD_LINUX=keep/#GRUB_GFXPAYLOAD_LINUX=keep/" /etc/default/grub
log info "Installing grub"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB &> /dev/null
log info "Generating grub config"
grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null

log info "Configuring mkinitcpio"
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.arbak
sed -i "s:BINARIES=():BINARIES=(/usr/bin/btrfs):" /etc/mkinitcpio.conf
sed -i "s/^HOOKS=([a-zA-Z0-9\-_ ]*)/HOOKS=(base systemd autodetect keyboard modconf block sd-encrypt filesystems fsck)/" /etc/mkinitcpio.conf
# popsicle needs battery or it will show completely wrong battery levels
# also i915 to make no blinky
[ "$host" == "popsicle" ] && sed -i "s/MODULES=(.*)/MODULES=(battery i915)/" /etc/mkinitcpio.conf
log info "Rebuilding initramfs"
mkinitcpio -P &> /dev/null
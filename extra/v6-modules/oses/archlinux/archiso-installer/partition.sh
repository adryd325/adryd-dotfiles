#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib/log.sh

AR_MODULE="archinstall partitioning"
log tell "\"${installTargetDev:?}\", \"/dev/disk/by-partlabel/EFI\" and \"/dev/disk/by-partlabel/${host:?}\" will be formatted"

mountOptions=defaults,x-mount.mkdir
btrfsOptions=${mountOptions},compress=zstd,ssd,noatime,discard

log info "Clearing partition data"
log silly "Wipefs"
wipefs --all "${installTargetDev}" --force >/dev/null
log silly "Partprobe"
partprobe &>/dev/null

log info "Creating partition table"
sgdisk --clear \
    --new=1:0:+1G --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:0 --typecode=2:8309 --change-name=2:"${host}" \
    "${installTargetDev}" &>/dev/null

# give something?? a sec to catch up
log verb "Waiting on kernel to fix partitions"
sleep 5
log silly "Partprobe again"
partprobe &>/dev/null
log silly "Wait again"
sleep 5

# make the EFI partition
log info "Making boot partition"
mkfs.fat -F 32 -n EFI /dev/disk/by-partlabel/EFI &>/dev/null

log info "Making root partition"
log silly "cryptsetup luksFormat"
echo "${diskPassword}" | cryptsetup luksFormat /dev/disk/by-partlabel/"${host}" -q >/dev/null
log silly "cryptsetup open"
echo "${diskPassword}" | cryptsetup open /dev/disk/by-partlabel/"${host}" "${host}" >/dev/null
diskPassword=

log info "Making btrfs partition"
log silly "mkfs.btrfs"
mkfs.btrfs --force --label "${host}" /dev/mapper/"${host}" &>/dev/null
log silly "Mounting"
mount -t btrfs LABEL="${host}" /mnt

log info "Making btrfs subvolumes"
log silly "Making root"
btrfs subvolume create /mnt/root >/dev/null
log silly "Making home"
btrfs subvolume create /mnt/home >/dev/null
log silly "Making swap"
btrfs subvolume create /mnt/swap >/dev/null

log silly "Unmounting"
umount -R /mnt

log info "Mounting everything properly"
log silly "Mounting root"
mount -t btrfs -o "subvol=root,${btrfsOptions}" LABEL="${host}" /mnt
log silly "Mounting home"
mount -t btrfs -o "subvol=home,${btrfsOptions}" LABEL="${host}" /mnt/home
log silly "Mounting boot"
mount -o "${mountOptions}" /dev/disk/by-partlabel/EFI /mnt/boot

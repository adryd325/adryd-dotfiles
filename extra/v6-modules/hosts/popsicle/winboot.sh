#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="winboot"

sudo cp /usr/share/edk2-shell/x64/Shell.efi /boot/shellx64.efi
sudo tee /boot/loader/entries/windows11.conf >/dev/null <<EOF
title  Windows 11
efi /shellx64.efi
options -nointerrupt -nomap -noversion windows.nsh
EOF
sudo tee /boot/windows.nsh >/dev/null <<EOF
echo -off
cls
mode 240 75
echo Booting Windows 11 (DcsBoot)
FS1:EFI\VeraCrypt\DcsBoot.efi
EOF

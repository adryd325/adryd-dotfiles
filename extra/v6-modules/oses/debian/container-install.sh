#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
[[ "${USER}" != "root" ]] && echo "Please run as root" && exit 1

# Lang files
sed -i "s/#en_US-UTF-8 UTF-8/en_US-UTF-8 UTF-8/" /etc/locale.gen &>/dev/null
locale-gen
if ! grep "^LANG=en_US-UTF-8" /etc/locale.conf &>/dev/null; then
    echo "LANG=en_US-UTF-8" >>/etc/locale.conf
fi

# Update
apt-get update
apt-get upgrade -y

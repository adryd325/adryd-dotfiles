#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu

../../oses/archlinux/container-install.sh
../../common/bash/_install.sh globalInstall
../../oses/archlinux/pacman/multilib.sh
source ./constants.sh
source ../../lib/temp.sh
source ../../lib/log.sh
export AR_MODULE="aur-builds"
[[ "${USER}" != root ]] && log error "Please run as root" && exit 1

# Install dependencies
log info "Installing dependencies"
pacman -S base-devel git pacman-contrib --noconfirm # nginx

# nginx config
#log info "Installing nginx config"
#cp -f ./nginx.conf /etc/nginx/nginx.conf

if ! id "aur" &>/dev/null; then
    log info "Creating service user"
    useradd --home-dir /var/aur/ --create-home aur
fi

# Add sudoer config for aur builder
lockStr="## adryd-dotfiles-lock (aur-builds)"
if ! grep "^${lockStr}" /etc/sudoers &>/dev/null; then
    log info "Changing sudoers config"
    echo "${lockStr}" >>/etc/sudoers
    echo "aur ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/mkarchroot, /usr/bin/arch-nspawn, /usr/bin/makechrootpkg" >>/etc/sudoers
fi

(
    tempDir=$(mkTemp)
    cd "${tempDir}" || exit $?

    # Build and install aurutils
    if ! pacman -Q aurutils &>/dev/null; then
        log info "Building aurutils"
        git clone https://aur.archlinux.org/aurutils.git
        chown -R aur:aur "${tempDir}"
        cd ./aurutils || exit $?
        sudo -u aur makepkg -s --noconfirm
        pacman -U --noconfirm aurutils-*.pkg.tar.zst
    fi
)

# Do the createring
if ! [[ -f "${REPO_ROOT}/${REPO_NAME}.db.tar.zst" ]]; then
    mkdir -p "${REPO_ROOT}"
    log info "Creating repo"
    repo-add "${REPO_ROOT}/${REPO_NAME}.db.tar.zst"
    sudo chown -R aur:aur "${REPO_ROOT}"
fi

# Add to pacman.conf
lockStr="## adryd-dotfiles-lock (hosts/aur-builds)"
if ! grep "^${lockStr}" /etc/pacman.conf &>/dev/null; then
    log info "Adding repo to pacman config"
    cat <<EOF >>/etc/pacman.conf
${lockStr}
[${REPO_NAME}]
SigLevel = Optional TrustAll
Server = file://${REPO_ROOT}
EOF
fi

# Place files in their new home
log info "Installing files"
mkdir /var/aur/logs 2>/dev/null
cp -f ./constants.sh /var/aur
cp -f ./build.sh /var/aur
ln -sf "$(realpath ./package-list.sh)" /var/aur

chown aur:aur ./constants.sh ./build.sh ./package-list.sh
chown aur:aur /var/aur/logs

# Install systemd units
log info "Installing systemd unit"
cp -f ./aur-builds.service /etc/systemd/system/aur-builds.service
cp -f ./aur-builds.timer /etc/systemd/system/aur-builds.timer
log info "Enabling systemd unit"
systemctl enable aur-builds.timer
systemctl start aur-builds.service &>/dev/null &

# Start nginx
#log info "Enabling nginx"
#systemctl enable --now nginx

log tell "You must create a GPG key to sign packages, or remove --sign from /var/aur/build.sh"

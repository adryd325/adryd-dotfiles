#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib.sh
source ../variables.sh
AR_MODULE="discord moonlight install"

# Clone the repo if we don't have it, and if we might have keys
if [[ ! -d "${moonlightDir}" ]] && [[ -e "${HOME}/.ssh" ]]; then
    log info "Cloning moonlight"
    if ! git clone git@github.com:moonlight-mod/moonlight.git "${moonlightDir}" --quiet; then
        log error "Failed to clone moonlight"
        exit 1
    fi
else
    log info "Pulling latest changes"
    (
        cd "${moonlightDir}" || exit 1
        git pull
    )
fi

if [[ ! -e "${moonlightConfigDir}" ]]; then
    log info "Linking config folder"
    if [[ "$(ar_get_distro)" == "macos" ]]; then
        ar_install_symlink "./macos" "${moonlightConfigDir}"
    else
        ar_install_symlink "./linux" "${moonlightConfigDir}"
    fi
fi

(
    cd "${moonlightDir}" || exit $?
    log info "Installing dependencies"
    pnpm i
    log info "Building"
    pnpm build
    log info "Building browser-mv2"
    pnpm run browser-mv2
)

AR_MODULE="discord moonlight install extensions"
if [[ -d "${moonlightExtensionsDir}" ]]; then
    log info "Pulling latest changes"
    (
        cd "${moonlightExtensionsDir}" || exit 1
        git pull
        log info "Installing dependencies"
        pnpm i
        log info "Building"
        pnpm build
    )
fi

AR_MODULE="discord moonlight install private"
# Clone the repo if we don't have it, and if we might have keys
if [[ ! -d "${moonlightPrivateDir}" ]] && [[ -e "${HOME}/.ssh" ]]; then
    log info "Cloning moonlight-trade-secrets"
    if ! git clone git@github.com:notnite/moonlight-trade-secrets.git "${moonlightPrivateDir}" --quiet; then
        log error "Failed to clone moonlight-trade-secrets, likely a permission issue"
        exit 1
    fi
else
    log info "Pulling latest changes"
    (
        cd "${moonlightPrivateDir}" || exit 1
        git pull
    )
fi

(
    cd "${moonlightPrivateDir}" || exit $?
    log info "Installing dependencies"
    pnpm i
    log info "Building"
    pnpm build
)

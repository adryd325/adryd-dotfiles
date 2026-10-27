#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
source ./variables.sh
AR_MODULE="discord wmclass-fix"

if [[ "$(ar_get_distro)" == "macos" ]]; then
    log info "Not applicable to macos"
    exit 1
fi

function patch_branch {
    branch=$1
    AR_LOG_PREFIX="${branch}"
    pkgName=$(get_discord_pkg_name "${branch}")
    installationDir=$(get_discord_installation_path "${branch}")

    if [[ -d "${installationDir}" ]]; then
        # TODO: Create a package.json and app bootstrap that loads the real asar in the case
        # hh isnt already installed
        if ! [[ -d "${installationDir}/resources/app" ]] && [[ -x "$(command -v asar)" ]]; then
            log info "Extracting asar"
            asar e "${installationDir}/resources/app.asar" "${installationDir}/resources/app"
        fi
        log info "Patching"
        sed -i "s/discord/${pkgName}/" "${installationDir}/resources/app/package.json"
    fi
}

if [[ $# -gt 0 ]]; then
    for branch in "$@"; do
        if ! is_valid_discord_branch "${branch}"; then
            log warn "The branch \"${branch}\" does not exist"
            continue
        fi
        patch_branch "${branch}" &
    done
    wait
else
    for branch in "${discordBranches[@]}"; do
        patch_branch "${branch}" &
    done
    wait
fi

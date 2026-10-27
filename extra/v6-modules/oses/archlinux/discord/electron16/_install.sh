#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../../common/discord/versions.sh
source ../../../../lib/temp.sh
source ../../../../lib/os.sh
source ../../../../lib/log.sh
export AR_MODULE="discord-electron16"

ensureInstalled electron16
workDir=$(mkTemp)

cp -r /usr/lib/electron16 "${workDir}/electron"
rm -r "${workDir}/electron/resources"

function patchBranch {
    branch=$1
    AR_LOG_PREFIX="${branch}"
    name=$(getDiscordName "${branch}")
    installationDir="${HOME}/.local/share/${name}"

    if [[ -d "${installationDir}" ]]; then
        log info "Replacing existing electron version"
        cp -rf "${workDir}/electron/"* "${installationDir}"
        cp -rf "${installationDir}/electron" "${installationDir}/${name}"
        if [[ -f "${installationDir}/resources/app/package.json" ]] && ! [[ -f "${installationDir}/resources/app2.asar" ]]; then
            log info "Fixing HH installation"
            sed -i "s/app.asar/app2.asar/g" "${installationDir}/resources/app/app_bootstrap/index.js"
            mv "${installationDir}/resources/app.asar" "${installationDir}/resources/app2.asar"
        fi
    fi
}

if [[ $# -gt 0 ]]; then
    for branch in "$@"; do
        if ! isValidBranch "${branch}"; then
            log warn "The branch \"${branch}\" does not exist"
            continue
        fi
        patchBranch "${branch}" &
    done
    wait
else
    for branch in "${DISCORD_BRANCHES[@]}"; do
        patchBranch "${branch}" &
    done
    wait
fi

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../../lib.sh
source ../variables.sh
AR_MODULE="discord moonlight patch"

function patch_branch_linux() {
    configPath=$(get_discord_config_path "${branch}")
    binaries=("${configPath}"/app*)
    pkgName=$(get_discord_pkg_name "${branch}")
    for version in "${binaries[@]}"; do
        resourcesPath="${version}/resources"
        (
            cd "${resourcesPath}" || exit 1
            mv app.asar _app.asar || exit 1
            mkdir -p app/app_bootstrap
            cat <<EOF >app/package.json
{
  "name": "${pkgName}",
  "main": "./app_bootstrap/index.js",
  "private": true
}
EOF
            cat <<EOF >app/app_bootstrap/index.js
require("${moonlightDir}/dist/injector.js").inject(require("path").resolve(__dirname + "../../_app.asar"));require("../../_app.asar");process.mainModule = require.cache[require.resolve("../../_app.asar")];
EOF
        )
    done
}

function patch_branch() {
    branch=$1
    AR_LOG_PREFIX="${branch}"

    if [[ "$(ar_get_distro)" != "macos" ]]; then
        patch_branch_linux "${branch}"
        return
    fi

    binaryPath=$(get_discord_binary_path "${branch}")
    pkgName=$(get_discord_pkg_name "${branch}")
    if [[ -x "${binaryPath}" ]]; then
        resourcesPath="$(dirname "${binaryPath}")/resources"
        (
            cd "${resourcesPath}" || exit 1
            mv app.asar _app.asar || exit 1
            mkdir -p app/app_bootstrap
            cat <<EOF >app/package.json
{
  "name": "${pkgName}",
  "main": "./app_bootstrap/index.js",
  "private": true
}
EOF
            cat <<EOF >app/app_bootstrap/index.js
require("${moonlightDir}/dist/injector.js").inject(require("path").resolve(__dirname + "../../../_app.asar"));require("../../_app.asar");process.mainModule = require.cache[require.resolve("../../_app.asar")];
EOF
        )
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

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
source ./variables.sh
AR_MODULE="discord linux-install"

if [[ "$(ar_get_distro)" == "macos" ]]; then
    log info "Not compatible with macos"
    exit 1
fi

tempDir=$(ar_mktemp)

function install_branch {
    branch=$1
    AR_LOG_PREFIX="${branch}"
    binaryName=$(get_discord_binary_name "${branch}")
    pkgName=$(get_discord_pkg_name "${branch}")
    installationDir=$(get_discord_installation_path "${branch}")
    desktopFile="${installationDir}/${pkgName}.desktop"

    log info "Downloading"
    if ! ar_download "$(get_discord_linux_download_url "${branch}")" "${tempDir}/${binaryName}.tar.gz"; then
        log error "Failed to download"
        return 1
    fi

    if [[ -d "${installationDir}" ]]; then
        log info "Deleting existing installation"
        rm -rf "${installationDir}"
    fi

    log info "Extracting"
    tar -xf "${tempDir}/${binaryName}.tar.gz" -C "${tempDir}" || return
    mv "${tempDir}/${binaryName}" "${HOME}/.local/share"

    log info "Installing"

    # The new (May 2021) icon looks too big on the GNOME dock
    if [[ -x "$(command -v magick)" ]]; then
        log verb "Add margin to the icon"
        magick \
            "${installationDir}/discord.png" \
            -bordercolor Transparent \
            -compose copy \
            -border 16 \
            -resize 256x256 \
            "${installationDir}/discord.png"
    fi
    # Check to make sure no existing icons exist
    log verb "Installing icon"
    mkdir -p "${HOME}/.local/share/icons/hicolor/256x256"
    cp -f "${installationDir}/discord.png" "${HOME}/.local/share/icons/hicolor/256x256/${pkgName}.png" &>/dev/null

    log verb "Patching .desktop file"
    sed -i "s:Exec=/usr/bin/${pkgName}:Exec=/usr/bin/env \"${installationDir}/${pkgName}\":" \
        "${desktopFile}"
    sed -i "s/StartupWMClass=discord/StartupWMClass=${pkgName}/" \
        "${desktopFile}"
    sed -i "s:Icon=${pkgName}:Icon=${HOME}/.local/share/icons/hicolor/256x256/${pkgName}.png:" \
        "${desktopFile}"
    sed -i "s:Path=/usr/bin:path=${installationDir}:" \
        "${desktopFile}"

    # Copy over new .desktop files
    log verb "Installing .desktop file"
    mkdir -p "${HOME}/.local/share/applications"
    cp -f "${installationDir}/${pkgName}.desktop" "${HOME}/.local/share/applications/${pkgName}.desktop"
}

if [[ $# -gt 0 ]]; then
    for branch in "$@"; do
        if ! is_valid_discord_branch "${branch}"; then
            log warn "The branch \"${branch}\" does not exist"
            continue
        fi
        install_branch "${branch}" &
    done
    wait
else
    install_branch stable
fi

rm -rf "${tempDir}"

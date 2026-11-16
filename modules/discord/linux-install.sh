#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
source ./variables.sh
AR_MODULE="discord linux-install"

if ar::is_macos || ar::is_nixos; then
    ar::log info "Not compatible with $(ar::get_distro)"
    exit 1
fi

tempDir=$(ar::mktemp)

function install_branch {
    branch=$1
    AR_LOG_PREFIX="${branch}"
    binaryName=$(get_discord_binary_name "${branch}")
    pkgName=$(get_discord_pkg_name "${branch}")
    installationDir=$(get_discord_installation_path "${branch}")
    desktopFile="${installationDir}/${pkgName}.desktop"

    ar::log info "Downloading"
    if ! ar::download "$(get_discord_linux_download_url "${branch}")" "${tempDir}/${binaryName}.tar.gz"; then
        ar::log error "Failed to download"
        return 1
    fi

    if [[ -d "${installationDir}" ]]; then
        ar::log info "Deleting existing installation"
        rm -rf "${installationDir}"
    fi

    ar::log info "Extracting"
    tar -xf "${tempDir}/${binaryName}.tar.gz" -C "${tempDir}" || return
    mv "${tempDir}/${binaryName}" "${HOME}/.local/share"

    ar::log info "Installing"

    # The new (May 2021) icon looks too big on the GNOME dock
    if [[ -x "$(command -v magick)" ]]; then
        ar::log verb "Add margin to the icon"
        magick \
            "${installationDir}/discord.png" \
            -bordercolor Transparent \
            -compose copy \
            -border 16 \
            -resize 256x256 \
            "${installationDir}/discord.png"
    fi
    # Check to make sure no existing icons exist
    ar::log verb "Installing icon"
    mkdir -p "${HOME}/.local/share/icons/hicolor/256x256"
    cp -f "${installationDir}/discord.png" "${HOME}/.local/share/icons/hicolor/256x256/${pkgName}.png" &>/dev/null

    ar::log verb "Patching .desktop file"
    sed -i "s:Exec=/usr/bin/${pkgName}:Exec=/usr/bin/env \"${installationDir}/${pkgName}\":" \
        "${desktopFile}"
    sed -i "s/StartupWMClass=discord/StartupWMClass=${pkgName}/" \
        "${desktopFile}"
    sed -i "s:Icon=${pkgName}:Icon=${HOME}/.local/share/icons/hicolor/256x256/${pkgName}.png:" \
        "${desktopFile}"
    sed -i "s:Path=/usr/bin:path=${installationDir}:" \
        "${desktopFile}"

    # Copy over new .desktop files
    ar::log verb "Installing .desktop file"
    mkdir -p "${HOME}/.local/share/applications"
    cp -f "${installationDir}/${pkgName}.desktop" "${HOME}/.local/share/applications/${pkgName}.desktop"
}

if [[ $# -gt 0 ]]; then
    for branch in "$@"; do
        if ! is_valid_discord_branch "${branch}"; then
            ar::log warn "The branch \"${branch}\" does not exist"
            continue
        fi
        install_branch "${branch}" &
    done
    wait
else
    install_branch stable
fi

rm -rf "${tempDir}"

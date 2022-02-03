#!/usr/bin/env bash
# shellcheck source=../../../constants.sh
[[ -z "${AR_DIR}" ]] && echo "Please set AR_DIR in your environment" && exit 0; source "${AR_DIR}"/constants.sh
ar_tmp
ar_os
AR_MODULE="discord"

downloadEndpoint='https://discord.com/api/download'
downloadOptions='?platform=linux&format=tar.gz'

installBranch() {
    branch=$1
    # fix variables for each branch
    # shellcheck source=../discord/discord-vars.sh
    source "${AR_DIR}/systems/personal/${AR_MODULE}/discord-vars.sh"

    AR_LOG_PREFIX="${branch}"
    log info "Downloading"
    mkdir -p "${workDir}"
    curl -fsSL "${downloadURL}" -o "${workDir}"/"${discordName}".tar.gz || return

    if [ -e "${HOME}/.local/share/${discordName}/${discordName}" ]; then
        log info "Deleting existing install"
        rm -rf "${HOME}/.local/share/${discordName}/"
    fi

    log info "Extracting"
    tar -xf "${workDir}/${discordName}.tar.gz" -C "${HOME}/.local/share" || return

    log info "Installing"
    # If no local icon folder exists, make one
    if [ ! -e "${HOME}/.local/share/icons/hicolor/256x256" ]; then
        log verb "Making icon folder"
        mkdir -p "${HOME}/.local/share/icons/hicolor/256x256"
    fi

    # The new (May 2021) icon looks too big on the GNOME dock
    if [ -e "$(command -v convert)" ]; then
        log verb "Add margin to the icon"
        convert \
            "${HOME}/.local/share/${discordName}/discord.png" \
            -bordercolor Transparent \
            -compose copy \
            -border 16 \
            -resize 256x256 \
            "${HOME}/.local/share/${discordName}/discord.png"
    fi
    # Check to make sure no existing icons exist
    if [ -e "${HOME}/.local/share/icons/hicolor/256x256/${discordLowercase}.png" ]; then
        log verb "Deleting existing icon"
        rm -rf "${HOME}/.local/share/icons/hicolor/256x256/${discordLowercase}.png"
    fi
    log verb "Linking icon"
    ln -s "${HOME}/.local/share/${discordName}/discord.png" "${HOME}/.local/share/icons/hicolor/256x256/${discordLowercase}.png"
    
    log verb "Patching .desktop file"
    sed -i "s:Exec=/usr/share/${discordLowercase}/${discordName}:Exec=\"${HOME}/.local/share/${discordName}/${discordName}\" -ignore-gpu-blocklist --disable-features=UseOzonePlatform --enable-features=VaapiVideoDecoder --use-gl=desktop --enable-gpu-rasterization --enable-zero-copy:" \
        "${HOME}"/.local/share/"${discordName}"/"${discordLowercase}".desktop
    sed -i "s/StartupWMClass=discord/StartupWMClass=${discordName}/" \
        "${HOME}"/.local/share/"${discordName}"/"${discordLowercase}".desktop
    sed -i "s:Icon=${discordLowercase}:Icon=${HOME}/.local/share/icons/hicolor/256x256/${discordLowercase}.png:" \
        "${HOME}"/.local/share/"${discordName}"/"${discordLowercase}".desktop
    sed -i "s:Path=/usr/bin:path=${HOME}/.local/share/${discordName}:" \
        "${HOME}"/.local/share/"${discordName}"/"${discordLowercase}".desktop

    # Delete existing .desktop files
    if [ -e "${HOME}/.local/share/applications/${discordLowercase}.desktop" ]; then
        log verb "Deleting existing .desktop file"
        rm -rf "${HOME}/.local/share/applications/${discordLowercase}.desktop"
    fi

    # Copy over new .desktop files
    log verb "Installing .desktop file"
    mkdir -p "${HOME}/.local/share/applications"
    cp -f "${HOME}/.local/share/${discordName}/${discordLowercase}.desktop" "${HOME}/.local/share/applications/${discordLowercase}.desktop"

    # Run discord postinst script
    # it errors cause of bad code :)
    # log verb "Running Discord's postinstall script"
    # $HOME/.local/share/$discordName/postinst.sh &> /dev/null
}

# not really dependent on any distros
if [ "${AR_OS_KERNEL}" == "linux" ] && [ -e "$(command -v curl)" ]; then
    if [[ "${AR_OS}" = "linux_arch" ]]; then
       cd "${AR_DIR}/systems/personal/${AR_MODULE}/discord-deps-local" &&
       yes | makepkg -si
    fi
    branches=("stable" "canary")
    if [ "${HOSTNAME}" == "popsicle" ]; then
        branches=("stable" "ptb" "canary" "development")
    fi

    [ -e "${AR_TMP}/discord" ] && rm -rf "${AR_TMP}/discord"
    [ ! -e "${HOME}/.local/share" ] && mkdir -p "${HOME}/.local/share"
    mkdir -p "${AR_TMP}/discord"
    workDir="${AR_TMP}/discord"

    for branch in "${branches[@]}"; do
        installBranch "${branch}" &
    done
    wait
    AR_LOG_PREFIX=""
fi

#!/usr/bin/env bash
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/temp.sh
source ../../lib/download.sh
source ../../lib/log.sh
source ../../lib/os.sh
AR_MODULE="firefox"

if [[ ! -e "${HOME}/.local/share/firefox-gnome-theme" ]]; then
    mkdir -p "${HOME}/.local/share"
    log info "Cloning firefox-gnome-theme"
    git clone https://github.com/rafaelmardojai/firefox-gnome-theme.git "${HOME}/.local/share/firefox-gnome-theme" --quiet
fi

if [[ -e "${HOME}/.local/share/firefox-gnome-theme" ]]; then
    (
        cd "${HOME}/.local/share/firefox-gnome-theme" || exit
        log info "Updating"
        git pull
    )
fi

moduleDir=$(pwd)

mapfile -t profilePaths <<<"$(grep -E "^Path=" "${HOME}/.mozilla/firefox/profiles.ini" | cut -d "=" -f2-)"

if [[ ${#profilePaths[@]} -eq 0 ]]; then
    log warn "No profiles found"
else
    log verb "${#profilePaths[@]} profiles found"
    for profilePath in "${profilePaths[@]}"; do
        AR_LOG_PREFIX="${profilePath}"
        # Move to work dir
        if [[ ! -d "${HOME}/.mozilla/firefox/${profilePath}" ]]; then
            log warn "${profilePath} does not exist"
            continue
        fi
        (
            cd "${HOME}/.mozilla/firefox/${profilePath}" || exit

            [[ ! -e "./chrome" ]] &&
                mkdir -p chrome &&
                log info "Creating chrome dir"
            cd chrome || exit

            [[ ! -e "./firefox-gnome-theme" ]] &&
                ln -sF "${HOME}/.local/share/firefox-gnome-theme" "${PWD}" &&
                log info "Installing firefox-gnome-theme"

            if [[ -e "./userChrome.css" ]]; then
                # Remove older theme imports
                sed -i 's/@import "firefox-gnome-theme.*.//g;/^\s*$/d' userChrome.css &&
                    log info "Removing older theme imports"
                echo >>./userChrome.css
            else
                echo >>./userChrome.css
            fi

            ln -sf "${HOME}/.local/share/firefox-gnome-theme" firefox-gnome-theme

            sed -i '1s/^/@import "firefox-gnome-theme\/userChrome.css";\n/' userChrome.css &&
                log info "Adding firefox-gnome-theme import to userChrome.css"

            cd ..

            # Copy user.js to the sync'ed one
            cp -f "${moduleDir}/user.js" user.js &&
                log info "Installed user.js"

            ICCProfile="$(colormgr get-devices | grep 'Metadata:\s*OutputEdidMd5=' | grep -oP '[0-9a-f]{32}')"
            sed -i "s|__REPLACE_ME__ICC_PROFILE_PATH__|${HOME}/.local/share/icc/edid-${ICCProfile}.icc|g" user.js && log info "Applied ICC profile"
        )
    done
    AR_LOG_PREFIX=""
fi

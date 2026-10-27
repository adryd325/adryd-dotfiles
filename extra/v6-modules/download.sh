#!/usr/bin/env bash
# .adryd v6
# bash -c "`curl -s adryd.co/install.sh`"
# bash -c "`wget -o- adryd.co/install.sh`"

# Installation dir
if [[ -z "${AR_DIR}" ]]; then
    if [[ "${USER}" == "root" ]]; then
        export AR_DIR="/opt/adryd-dotfiles"
    else
        export AR_DIR="${HOME}/.adryd"
    fi
fi

# Remote URLs
[[ -z "${AR_REMOTE_HTTPS_TAR}" ]] && AR_REMOTE_HTTPS_TAR="https://github.com/adryd325/dotfiles/archive/refs/heads/main.tar.gz"
[[ -z "${AR_REMOTE_GIT_HTTPS}" ]] && AR_REMOTE_GIT_HTTPS="https://github.com/adryd325/dotfiles.git"
[[ -z "${AR_REMOTE_GIT_SSH}" ]] && AR_REMOTE_GIT_SSH="git@github.com:adryd325/dotfiles.git"

function extract() {
    if [[ -x "$(command -v tar)" ]]; then
        echo "Extracting dotfiles bundle (tar)"
        if [[ -d "dotfiles-main" ]]; then
            echo '"dotfiles-main" folder already exists.  Please remove it to proceed with the installation.'
            exit 1
        fi
        tar -xf "$1"
        rm dotfiles-main.tar
        mkdir -p "$(dirname "${AR_DIR}")"
        mv dotfiles-main "${AR_DIR}"
        [[ -d "${AR_DIR}" ]] && return
        echo "Failed extract with tar"
    fi
}

function download() {
    # If we have git
    # TODO: Check if we don't actually have command-line tools so macOS shuts up
    if [[ -x "$(command -v git)" ]]; then
        if [[ -f "${HOME}/.ssh/id_ed25519" ]] || [[ -f "${HOME}/.ssh/id_rsa" ]]; then
            echo "Cloning dotfiles repo (git+ssh)"
            git clone "${AR_REMOTE_GIT_SSH}" "${AR_DIR}" -qq
            [[ -d "${AR_DIR}" ]] && return
            echo "Failed cloning dotfiles repo (git+ssh)"
        fi

        # fall through to https
        echo "Cloning dotfiles repo (git+https)"
        git clone "${AR_REMOTE_GIT_HTTPS}" "${AR_DIR}" -qq
        [[ -d "${AR_DIR}" ]] && return
        echo "Failed cloning dotfiles repo (git+https)"
    fi

    if [[ ! -f "dotfiles-main.tar" ]]; then

        if [[ -x "$(command -v curl)" ]]; then
            echo "Downloading dotfiles bundle (curl)"
            curl -sSo "dotfiles-main.tar" "${AR_REMOTE_HTTPS_TAR}"
            [[ -f "dotfiles-main.tar" ]] && extract "dotfiles-main.tar" && return
            echo "Failed to download (curl)"
        fi

        if [[ -x "$(command -v wget)" ]]; then
            echo "Downloading dotfiles bundle (wget)"
            wget -qO "dotfiles-main.tar" "${AR_REMOTE_HTTPS_TAR}"
            [[ -f "dotfiles-main.tar" ]] && extract "dotfiles-main.tar" && return
            echo "Failed to download (wget)"
        fi
    else
        if [[ -d "dotfiles-main" ]]; then
            echo '"dotfiles-main.tar" file already exists.  Please remove it to proceed with the installation.'
            exit 1
        fi
    fi

    echo "All download options failed"
    exit 1
}

if [[ -e "${AR_DIR}" ]]; then
    echo "\"${AR_DIR}\" already exists. Run existing install script? [Y/n]"
    read -r ask
    if [[ $(tr '[:upper:]' '[:lower:]' <<< "${ask}") != "N" ]]; then "${AR_DIR}/install.sh"; fi
    exit 0
fi

download || exit 1
echo "Downloaded to ${AR_DIR}"
sleep 1
"${AR_DIR}/install.sh"

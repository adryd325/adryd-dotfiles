#!/usr/bin/env bash

hhDir=${hhDir:="${HOME}/_/hh3"}
moonlightDir=${moonlightDir:="${HOME}/_/moonlight"}
moonlightExtensionsDir=${moonlightExtensionsDir:="${HOME}/_/moonlight-extensions-flagship"}
moonlightPrivateDir=${moonlightPrivateDir:="${HOME}/_/moonlight-extensions-private"}
if [[ "$(ar_get_distro)" == "macos" ]]; then
    hhConfigDir=${hhConfigDir:="${HOME}/Library/Application Support/hh3"}
    moonlightConfigDir=${moonlightConfigDir:="${HOME}/Library/Application Support/moonlight-mod"}
else
    hhConfigDir=${hhConfigDir:="${HOME}/.config/hh3"}
    moonlightConfigDir=${moonlightConfigDir:="${HOME}/.config/moonlight-mod"}
fi

export discordBranches=("stable" "ptb" "canary" "development")

downloadEndpoint='https://discord.com/api/download'
linuxDownloadOptions='?platform=linux&format=tar.gz'
function get_discord_linux_download_url {
    if [[ "$1" = "stable" ]] || [[ -z "$1" ]]; then
        echo "${downloadEndpoint}${linuxDownloadOptions}"
    else
        echo "${downloadEndpoint}/$1${linuxDownloadOptions}"
    fi
}

function is_valid_discord_branch {
    invalid=1
    for i in "${discordBranches[@]}"; do
        if [[ "${i}" = "$1" ]]; then
            invalid=0
        fi
    done
    return "${invalid}"
}

function get_discord_binary_name {
    branch=$1
    if [[ "${branch}" = "stable" ]]; then
        echo "Discord"
    elif [[ "${branch}" = "ptb" ]]; then
        echo "DiscordPTB"
    else
        echo "Discord${branch^}"
    fi
}

function get_discord_pretty_name {
    branch=$1
    if [[ "${branch}" = "stable" ]]; then
        echo "Discord"
    elif [[ "${branch}" = "ptb" ]]; then
        echo "Discord PTB"
    else
        echo "Discord ${branch^}"
    fi
}

function get_discord_pkg_name {
    branch=$1
    if [[ "${branch}" = "stable" ]]; then
        echo "discord"
    else
        echo "discord-${branch}"
    fi
}

function get_discord_installation_path {
    branch=$1
    if [[ "$(ar_get_distro)" == "macos" ]]; then
        echo "/Applications/$(get_discord_pretty_name "${branch}").app/"
    else
        echo "${HOME}/.local/share/$(get_discord_binary_name "${branch}")/"
    fi
}

function get_discord_binary_path {
    branch=$1
    if [[ "$(ar_get_distro)" == "macos" ]]; then
        echo "/Applications/$(get_discord_pretty_name "${branch}").app/Contents/MacOS/$(get_discord_pretty_name "${branch}")"
    else
        echo "${HOME}/.local/share/$(get_discord_binary_name "${branch}")/$(get_discord_binary_name "${branch}")"
    fi
}

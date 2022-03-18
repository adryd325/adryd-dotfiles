#!/usr/bin/env bash
function getKernel {
    printf %s "$(uname -s | tr '[:upper:]' '[:lower:]')"
}

function getDistro {
    if [[ "$(getKernel)" = "linux" ]] && [[ -f /etc/os-release ]]; then
        source /etc/os-release
        tr '[:upper:]' '[:lower:]' <<< "${ID/ /}" | sed 's/^arch$/archlinux/'
        return
    fi
    if [[ "$(getKernel)" = "darwin" ]]; then
        printf "macos"
        return
    fi
    printf "unknown"
}

function ensureInstalled {
    case "$(getDistro)" in
        "archlinux")
            pacman -Qe "$@" &> /dev/null && return
            pacmanWrapper="pacman"
            for wrapper in "paru" "yay"; do
                if [[ -x "$(command -v "${wrapper}")" ]]; then
                    pacmanWrapper="$(command -v "${wrapper}")"
                    break;
                fi
            done
            if [[ "${pacmanWrapper}" =~ yay|paru ]]; then
                "${pacmanWrapper}" -S "$@" --noconfirm --asexplicit --useask --removemake --needed || return $?
            else
                sudo "${pacmanWrapper}" -S "$@" --noconfirm --asexplicit --needed || return $?
            fi
            # TODO: AUR packages break this
            # "${pacmanWrapper}" -Spq "$@" --print-format "%n" | sudo pacman -Dq - --asexplicit
            sudo pacman -Dq "$@" --asexplicit 2> /dev/null
            ;;
        "nixos")
            echo "what the fuck are you doing"
            ;;
        "fedora")
            sudo dnf install -y "$@"
            ;;
        "macos")
            brew install "$@"
            ;;
        *)
            echo "ensureInstalled is not supported on this os"
            ;;
    esac
}

function ensureInstalledFlatpak {
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    for package in "$@"; do
        flatpak install "${package}"
    done
}
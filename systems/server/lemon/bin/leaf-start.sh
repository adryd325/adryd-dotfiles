#!/usr/bin/env bash
# --- BEGIN CONSTANTS --- 
#!/usr/bin/env bash
function ar_const() {
    # Utility function to make defining constants prettier
    [[ -z "${!1}" ]] && export "$1"="${*:2}"
}

# Remote URLs
ar_const AR_REMOTE_HTTPS_TAR "https://gitlab.com/adryd/dotfiles/-/archive/master/dotfiles-master.tar"
ar_const AR_REMOTE_GIT_HTTPS "https://gitlab.com/adryd/dotfiles.git"
ar_const AR_REMOTE_GIT_SSH "git@gitlab.com:adryd/dotfiles.git"


function ar_dir() {
    if [[ -z "$AR_DIR" ]]; then
        function check() {
            if [[ -f "$1/.manifest" ]] && [[ "$(cat "$1"/.manifest)" = "adryd-dotfiles-v5.1" ]]; then
                cd "$oldPwd" || exit 1
                export AR_DIR="$1"
                return 0
            fi
            return 1
        }
        local oldPwd=$PWD
        cd "$(dirname -- "$0")" || exit 1
        while [[ "$PWD" != '/' ]]; do check "$PWD" && return 0; cd ..; done
        cd "$oldPwd" || exit 1
        while [[ "$PWD" != '/' ]]; do check "$PWD" && return 0; cd ..; done
        cd "$oldPwd" || exit 1
        check "$HOME/.adryd" && return
        check "/root/.adryd" && return
        return 1
    fi
    return 0
}
ar_dir

function ar_splash() {
    if [[ -z "$AR_SPLASH" ]] && [[ "$0" = "$AR_DIR"* ]] || [[ "$AR_MODULE" = "download" ]]; then
        echo -en "\n \x1b[30;44m \x1b[0m .adryd\n \x1b[30;44m \x1b[0m version 5.1\n\n"
        export AR_SPLASH=1
    fi
}
ar_splash

function ar_os() {
    AR_OS_KERNEL="$(uname -s | tr '[:upper:]' '[:lower:]')"
    AR_OS_DISTRO="unk"
    AR_OS="unk"
    export AR_OS_KERNEL
    if [[ "$AR_OS_KERNEL" = "linux" ]]; then
        # This is what neofetch does, so I feel safe doing the same
        [[ -f /etc/os-release ]] && source /etc/os-release
        AR_OS_DISTRO="$(echo $ID | sed 's/ //g' | tr '[:upper:]' '[:lower:]')"
        AR_OS="${AR_OS_KERNEL}_$AR_OS_DISTRO"
    fi
    if [[ "$AR_OS_KERNEL" = "darwin" ]]; then
        AR_OS_DISTRO="macos"
        AR_OS="${AR_OS_KERNEL}_$AR_OS_DISTRO"
    fi
    export AR_OS_DISTRO
    export AR_OS
}

function ar_tmp() {
    if [[ -z "$AR_TMP" ]]; then
        local tmpPrefix=""
        if [[ -n "$AR_MODULE" ]]; then
            tmpPrefix=".$AR_MODULE"
        fi
        if [[ -x "$(command -v mktemp)" ]]; then
            AR_TMP="$(mktemp -d -t "adryd-dotfiles$tmpPrefix.XXXXXXXXXX")" 
            export AR_TMP
        else
            for tempDir in "$TMPDIR" "$TMP" "$TEMP" /tmp; do
                if [[ -d "$tempDir" ]]; then
                    AR_TMP="$tempDir/adryd-dotfiles$tmpPrefix.$RANDOM"
                    export AR_TMP
                    break
                fi
            done
        fi
        if [[ -z "$AR_TMP" ]]; then
            log error "Could not find temp folder"
            exit 1
        fi
    fi
}

function ar_local {
    ar_os
    if [[ "$AR_KERNEL" = "darwin" ]]; then
        ar_const AR_LOCAL "$HOME/Library/Application\ Support/adryd-dotfiles"
        ar_const AR_CACHE "$HOME/Library/Caches/adryd-dotfiles"
    else 
        ar_const AR_LOCAL "$HOME/.config/adryd-dotfiles"
        ar_const AR_CACHE "$HOME/.cache/adryd-dotfiles"
    fi
}

function log() {
    local echoArgs="-e"
    local logString=""
    local logLevel=0
    case $1 in
        silly)
            logLevel=0
            logString+="\x1b[30;47msill\x1b[0m "
            ;;
        verb)
            logLevel=1
            logString+="\x1b[34;40mverb\x1b[0m "
            ;;
        info)
            logLevel=2
            logString+="\x1b[36minfo\x1b[0m "
            ;;
        warn)
            logLevel=3
            logString+="\x1b[30;43mWARN\x1b[0m "
            ;;
        error)
            logLevel=4
            logString+="\x1b[30;41mERR!\x1b[0m "
            ;;
        tell)
            logLevel=5
            logString+="\x1b[32mtell\x1b[0m "
            ;;
        ask)
            logLevel=5
            logString+="\x1b[32mask:\x1b[0m "
            echoArgs="-en"
            ;;
    esac
    [[ -n "$AR_MODULE" ]] && logString+="\x1b[35m$AR_MODULE\x1b[0m "
    [[ -n "$AR_LOG_PREFIX" ]] && logString+="\x1b[32m($AR_LOG_PREFIX)\x1b[0m "
    logString+="${*:2}"
    [[ -n $AR_LOGLEVEL ]] && [[ $logLevel -lt $AR_LOGLEVEL ]] && [[ $logLevel -lt 5 ]] && return
    echo $echoArgs "$logString"
}

function ar_keyring() {
    ar_os
    local keyringId="C63B-065C"
    local keyringDev="/dev/disk/by-uuid/$keyringId"
    if [[ "$AR_OS" = "linux_arch" ]] && [[ -e "$keyringDev" ]]; then
        if [[ "$1" = "umount" ]]; then
            if [[ -e "/dev/mapper/keyring-encrypt" ]]; then
                sudo umount "/dev/mapper/keyring-encrypt"
                sudo cryptsetup close "keyring-encrypt"
            fi
            if [[ -e "$keyringDev" ]]; then
                sudo umount "$keyringDev"
            fi
        else 
            local keyringDir
            if mountpoint "/run/media/adryd/KEYRING" &> /dev/null; then
                keyringDir=/run/media/adryd/KEYRING
                keyringEncryptDir=/run/media/adryd/KEYRING/keyring-encrypt
                if ! mountpoint "$keyringEncryptDir" &> /dev/null && [[ -d "$keyringEncryptDir" ]]; then
                    if [[ -e "/dev/mapper/keyring-encrypt" ]]; then
                        sudo cryptsetup close "keyring-encrypt"
                    fi
                    sudo cryptsetup open "$keyringDir/keyring-encrypt.ext4.luks2" "keyring-encrypt"
                    sudo mount "/dev/mapper/keyring-encrypt" "$keyringEncryptDir"
                fi
                export AR_KEYRING=$keyringEncryptDir
            else
                keyringDir=/tmp/adryd-dotfiles-mnt/keyring
                keyringEncryptDir=/tmp/adryd-dotfiles-mnt/keyring-encrypt
                if ! mountpoint "$keyringEncryptDir" &> /dev/null; then
                    if ! mountpoint "$keyringEncryptDir" &> /dev/null && [[ -e "/dev/mapper/keyring-encrypt" ]]; then
                        sudo cryptsetup close "keyring-encrypt"
                    fi
                    sudo mkdir -p "$keyringDir" "$keyringEncryptDir"
                    sudo mount "$keyringDev" "$keyringDir"
                    sudo cryptsetup open "$keyringDir/keyring-encrypt.ext4.luks2" "keyring-encrypt"
                    sudo mount "/dev/mapper/keyring-encrypt" "$keyringEncryptDir"
                fi
                export AR_KEYRING=$keyringEncryptDir
            fi
        fi
    fi
}
# --- END CONSTANTS ---
export AR_MODULE=''

gpuVM="1000"
VM=$1

if [ "$USER" != "root" ]; then
    log error "Please run as root"
    exit 1
fi

if [ ! -e "/etc/pve/qemu-server/$VM.conf" ]; then
    log error "Unknown VM: $VM"
    exit 1
fi

if [ "$(qm status $gpuVM)" == "status: running" ]; then
    log info "Shutting down $gpuVM"
    qm shutdown "$gpuVM" &> /dev/null || log info "Forcing shut down $gpuVM" && qm stop "$gpuVM"
fi
sleep 1

qm set "$gpuVM" --onboot 0 > /dev/null && log info "Disable automatic boot on $gpuVM"
qm set "$VM" --onboot 1 --hostpci0 01:00,pcie=1,x-vga=1 --usb0 host=046d:c332 --usb1 host=046d:c336 --usb2 host=1-9 --usb3 host=2-9 --vga none > /dev/null && log info "Passthrough hardware to $VM"

log info "Starting $VM"
qm start "$VM"

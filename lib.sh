#!/usr/bin/env bash
# source lib.sh

# Usage: log <level> <message>
function log {
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
    *)
        logLevel=0
        logString+="\x1b[30;47minvalid log level\x1b[0m "
        ;;

    esac
    [[ -n "${AR_MODULE}" ]] && logString+="\x1b[33m${AR_MODULE}\x1b[0m "
    [[ -n "${AR_LOG_PREFIX:=}" ]] && logString+="\x1b[31m(${AR_LOG_PREFIX})\x1b[0m "
    logString+="${*:2}"
    [[ -z ${AR_LOGLEVEL:=} ]] && AR_LOGLEVEL=2
    [[ ${logLevel} -lt ${AR_LOGLEVEL} ]] && [[ ${logLevel} -lt 5 ]] && return
    echo "${echoArgs}" "${logString}"
}

# Usage: ar_mktemp
# Prints created temp folder to stdout. Exits with 1 if failed
function ar_mktemp {
    local tmpPrefix=""
    if [[ -n "${AR_MODULE}" ]]; then
        tmpPrefix=".${AR_MODULE}"
    fi
    if [[ -x "$(command -v mktemp)" ]]; then
        mktemp -d -t "adryd-dotfiles${tmpPrefix}.XXXXXXXXXX"
        return 0
    else
        # if we dont have mktemp
        for tempDir in "${TMPDIR}" /tmp; do
            if [[ -d "${tempDir}" ]]; then
                echo "${tempDir}/adryd-dotfiles${tmpPrefix}.${RANDOM}"
                return 0
            fi
        done
    fi
    echo "ar_mktemp: failed to find location for temp folder" >>/dev/stderr
    return 1
}

# Usage: ar_get_kernel
# Prints kernel name to stdout
function ar_get_kernel {
    uname -s | tr '[:upper:]' '[:lower:]'
}

# Usage: ar_get_distro
# Prints distro to stdout
function ar_get_distro {
    if [[ "$(ar_get_kernel)" = "linux" ]] && [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        # shellcheck disable=SC2154
        tr '[:upper:]' '[:lower:]' <<<"${ID/ /}" | sed 's/^arch$/archlinux/'
        return 0
    fi
    if [[ "$(ar_get_kernel)" = "darwin" ]]; then
        echo "macos"
        return 0
    fi
    echo "unknown"
    echo "ar_mktemp: failed to detect distro" >>/dev/stderr
    return 1
}

# Usage: ar_chk_command_line_tools
# Exits with 0 if command line tools are installed, and exits with 1 if they're
# not
function ar_chk_command_line_tools {
    if [[ "$(ar_get_distro)" = "macos" ]] && ! xcode-select -p &>/dev/null; then
        return 1
    fi
}

# Usage: __ar_install_internal <type> <elevated> <source> <destination>
function __ar_install_internal {
    local type="$1"
    local elevated="$2"
    local source
    source="$(realpath "$3")"
    local destination="$4"

    local date
    date=$(date '+%Y-%m-%d')
    local orig="${destination}.${date}.orig"

    local run_as=()
    if [[ "${elevated}" = "yes" ]]; then
        run_as=(sudo)
    fi

    if [[ "${type}" != "file" ]] && [[ "${type}" != "symlink" ]]; then
        echo '__ar_install_internal: argument 1 (type) not of "file" or "symlink"' >>/dev/stderr
        return 1
    fi

    if [[ -e "${destination}" ]]; then

        if [[ "${type}" = "symlink" ]] && [[ "$("${run_as[@]}" readlink "${destination}")" = "${source}" ]]; then
            return 0
        fi

        if [[ "${type}" = "file" ]] && "${run_as[@]}" cmp -sh "${source}" "${destination}"; then
            return 0
        fi

        "${run_as[@]}" mv "${destination}" "${orig}"

        if [[ "${type}" = "symlink" ]]; then
            "${run_as[@]}" ln -sf "${source}" "${destination}" && return 0
        fi

        if [[ "${type}" = "file" ]]; then
            "${run_as[@]}" cp "${source}" "${destination}" && return 0
        fi
    else
        if [[ "${type}" = "symlink" ]]; then
            "${run_as[@]}" ln -sf "${source}" "${destination}" && return 0
        fi

        if [[ "${type}" = "file" ]]; then
            "${run_as[@]}" cp "${source}" "${destination}" && return 0
        fi
    fi

    return 1
}

# Usage: ar_install_file <source> <destination>
# Copies a file to the destination, making a backup of the original file in the
# process.
function ar_install_file {
    __ar_install_internal file no "$1" "$2"
}

# Usage: ar_install_file_el <source> <destination>
# Copies a file to the destination, making a backup of the original file in the
# process. With sudo.
function ar_install_file_el {
    __ar_install_internal file yes "$1" "$2"
}

# Usage: ar_install_symlink <source> <destination>
# Symlinks a file to the destination, making a backup of the original file in
# the process.
function ar_install_symlink {
    __ar_install_internal symlink no "$1" "$2"
}

# Usage: ar_install_symlink_el <source> <destination>
# Symlinks a file to the destination, making a backup of the original file in
# the process. With sudo.
function ar_install_symlink_el {
    __ar_install_internal symlink yes "$1" "$2"
}

# Usage: __ar_remove_block <start> <end>
# Takes content as stdin, removes a block defined by input, and prints output
function __ar_remove_block {
    local issegmentstarted=false
    while read -r line; do
        if [[ "$1" = "${line}" ]]; then
            issegmentstarted=true
            continue
        fi
        if [[ "${issegmentstarted}" = true ]]; then
            if [[ "$2" = "${line}" ]]; then
                issegmentstarted=false
            fi
            continue
        fi
        echo "${line}"
    done </dev/stdin

    if [[ "${issegmentstarted}" = true ]]; then
        echo "__ar_remove_block: unexpected end of input" >>/dev/stderr
        return 1
    fi
}

# Usage: __ar_install_snippet_internal <elevated> <destination> <blockstringstart> <blockstringend>
function __ar_install_snippet_internal {
    local destination=$2
    local elevated=$1

    local run_as=()
    if [[ "${elevated}" = "yes" ]]; then
        run_as=(sudo)
    fi
    if [[ ! -e "${destination}" ]]; then
        "${run_as[@]}" touch "${destination}"
    fi

    local scratchfile
    scratchfile="$(ar_mktemp)/scratchfile"
    __ar_remove_block "$3" "$4" <"${destination}" | "${run_as[@]}" tee "${scratchfile}" >/dev/null && "${run_as[@]}" mv "${scratchfile}" "${destination}" || return 1

    echo "$3" | "${run_as[@]}" tee -a "${destination}" >/dev/null
    while read -r line; do
        echo "${line}" | "${run_as[@]}" tee -a "${destination}">/dev/null
    done </dev/stdin
    echo "$4" | "${run_as[@]}" tee -a "${destination}" >/dev/null
    return 0
}

# Usage: ar_install_snippet <destination> <blockstringstart> <blockstringend>
# Write snippet contents to stdin
function ar_install_snippet {
    __ar_install_snippet_internal no "$@" </dev/stdin
}

# Usage: ar_install_snippet_el <destination> <blockstringstart> <blockstringend>
# Write snippet contents to stdin
function ar_install_snippet_el {
    __ar_install_snippet_internal yes "$@" </dev/stdin
}

# Usage: ar_download <url> <destination>
# Download contents of URL to file using either curl or wget depending on which
# is available
function ar_download {
    if [[ -x "$(command -v curl)" ]]; then
        curl -fsSL "$1" -o "$2"
        return $?
    elif [[ -x "$(command -v wget)" ]]; then
        wget -qo "$2" "$1"
        return $?
    fi
    echo "ar_download: failed to download $1. curl or wget not installed" >>/dev/stderr
    return 1
}

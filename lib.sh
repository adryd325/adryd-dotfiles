#!/usr/bin/env bash

#######################################
# Log a message.
# Globals:
#   AR_MODULE
#   AR_LOG_PREFIX
#   AR_LOGLEVEL
# Arguments:
#   Log level: One of verb, info, warn, error, tell, or ask
#   String to log
#######################################
function ar::log {
	local echo_args="-e"
	local log_string=""
	local -i log_level=0
	case $1 in
	verb)
		log_level=1
		log_string+="\x1b[34;40mverb\x1b[0m "
		;;
	info)
		log_level=2
		log_string+="\x1b[36minfo\x1b[0m "
		;;
	warn)
		log_level=3
		log_string+="\x1b[30;43mWARN\x1b[0m "
		;;
	error)
		log_level=4
		log_string+="\x1b[30;41mERR!\x1b[0m "
		;;
	tell)
		log_level=5
		log_string+="\x1b[32mtell\x1b[0m "
		;;
	ask)
		log_level=5
		log_string+="\x1b[32mask:\x1b[0m "
		echo_args="-en"
		;;
	*)
		log_level=0
		log_string+="\x1b[30;47minvalid log level\x1b[0m "
		;;
	esac

	if [[ -n "${AR_MODULE}" ]]; then
		log_string+="\x1b[33m${AR_MODULE}\x1b[0m "
	fi

	if [[ -n "${AR_LOG_PREFIX:=}" ]]; then
		log_string+="\x1b[31m(${AR_LOG_PREFIX})\x1b[0m "
	fi
	# The rest of the args are the string to log
	log_string+="${*:2}"

	if [[ -z ${AR_LOGLEVEL:=} ]]; then
		AR_LOGLEVEL=2
	fi

	# Always log if log_level greater than 4
	if [[ ${log_level} -lt "${AR_LOGLEVEL}" ]] && [[ ${log_level} -lt 5 ]]; then
		return
	fi
	echo "${echo_args}" "${log_string}" >&2
}

#######################################
# Log a message but for library.
# Globals:
#   None
# Arguments:
#   Log level: One of verb, info, warn, error, tell, or ask
#   Function: Function logging
#   String to log
#######################################
function ar::__lib_log {
	ar::log "$1" "\x1b[32m(ar::$2)\x1b[0m" "${*:3}"
}

#######################################
# Demo of log function
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::__log_preview {
	AR_MODULE=lib ar::log info "This is the logging library in .adryd/lib.sh"
	AR_MODULE=lib ar::log info "This is an INFO message"
	AR_MODULE="" ar::log info "AR_MODULE specifies the module prefix"
	AR_MODULE="discord" AR_LOG_PREFIX="canary" ar::log info "We use \
AR_LOG_PREFIX from time to time. In this example the Discord module is \
installing the canary branch"

	AR_MODULE="discord" AR_LOG_PREFIX="canary" ar::__lib_log error __log_preview \
		"lib.sh has a special log function that preserves AR_MODULE and \
AR_LOG_PREFIX to provide a bit of a stack trace when debugging"

	AR_LOGLEVEL=0
	AR_MODULE="lib" ar::log error "Here's an error!"
	AR_MODULE="lib" ar::log warn "A warning!"
	AR_MODULE="lib" ar::log info "Another info"
	AR_LOGLEVEL=0 AR_MODULE="lib" ar::log verb "Verbose"
	AR_LOGLEVEL=0 AR_MODULE="lib" ar::log ask "A question? your input here: \n"
	AR_LOGLEVEL=0 AR_MODULE="lib" ar::log tell "And finally, tell will always \
be logged regardless of log level"
}

#######################################
# Creates a temp folder agnostic of operating system. Prints created temp folder
# to stdout. Exits with 1 if failed.
# Globals:
#   AR_MODULE
# Arguments:
#   None
#######################################
function ar::mktemp {
	local tmp_prefix=""
	local dir=""
	if [[ -n "${AR_MODULE-}" ]]; then
		tmp_prefix=".${AR_MODULE}"
	fi
	if [[ -x "$(command -v mktemp)" ]]; then
		dir="$(mktemp -d -t "adryd-dotfiles${tmp_prefix}.XXXXXXXXXX")"
		ar::__lib_log verb mktemp "created ${dir}"
		echo "${dir}"
		return 0
	else
		# if we dont have mktemp
		for tempDir in "${TMPDIR}" /tmp; do
			if [[ -d "${tempDir}" ]]; then
				dir="${tempDir}/adryd-dotfiles${tmp_prefix}.${RANDOM}"
				ar::__lib_log verb mktemp "created ${dir}"
				echo "${dir}"
				return 0
			fi
		done
	fi
	ar::__lib_log error mktemp "failed to find a location for a temp folder"
	return 1
}

#######################################
# Prints lowercase kernel to stdout
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::get_kernel {
	uname -s | tr '[:upper:]' '[:lower:]'
}

#######################################
# Prints normalised OS name to stdout. This is known to work on the following
# OSes: archlinux, fedora, debian, nixos, alpine, macos, ios
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::get_distro {
	if [[ "$(ar::get_kernel)" = "linux" ]] && [[ -f /etc/os-release ]]; then
		# This isn't ideal but neofetch does it /shrug
		# shellcheck disable=SC1091
		source /etc/os-release
		# shellcheck disable=SC2154
		tr '[:upper:]' '[:lower:]' <<<"${ID/ /}" | sed 's/^arch$/archlinux/'
		return 0
	fi
	if [[ "$(ar::get_kernel)" = "darwin" ]]; then
		if [[ "$(sw_vers -productName)" = "macOS" ||
		"$(sw_vers -productName)" = "Mac OS X" ]]; then
			echo "macos"
			return 0
		elif [[ "$(sw_vers -productName)" = "iPhone OS" ]]; then
			echo "ios"
			return 0
		fi
		return 0
	fi
	echo "unknown"
	ar::__lib_log warn get_distro "failed to detect operating system"
	return 1
}

#######################################
# Exits 0 if macos, Exits 1 if not
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::is_macos {
	if [[ "$(ar::get_distro)" = "macos" ]]; then
		return 0
	fi
	return 1
}

#######################################
# Exits 0 if nixos, Exits 1 if not
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::is_nixos {
	if [[ "$(ar::get_distro)" = "nixos" ]]; then
		return 0
	fi
	return 1
}

#######################################
# Exits 0 if linux, Exits 1 if not
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::is_linux {
	if [[ "$(ar::get_kernel)" = "linux" ]]; then
		return 0
	fi
	return 1
}


#######################################
# Exits with 0 if command line tools are installed, and exits with 1 if they're
# not
# Globals:
#   None
# Arguments:
#   None
#######################################
function ar::chk_command_line_tools {
	if [[ "$(ar::get_distro)" = "macos" ]] && ! xcode-select -p &>/dev/null; then
		return 1
	fi
}

#######################################
# Internal ar::install logic
# Globals:
#   None
# Arguments:
#   Type: One of "file" or "symlink"
#   Boolean whether to run as sudo or not
#   Source file
#   Destination path
#######################################
function ar::__install_internal {
	local type="$1"
	local elevated="$2"
	local source
	source="$(realpath "$3")"
	local destination="$4"

	local date
	date=$(date '+%Y-%m-%d')
	local orig="${destination}.${date}.orig"

	local run_as=()
	if [[ "${elevated}" = true ]]; then
		run_as=(sudo)
	fi

	if [[ "${type}" != "file" ]] && [[ "${type}" != "symlink" ]]; then
		ar::_lib_log error __install_internal 'argument 1 (type) not of "file" or \
"symlink"'
		return 1
	fi

	if [[ -e "${destination}" ]]; then

		if [[ "${type}" = "symlink" ]] &&
			[[ "$("${run_as[@]}" readlink "${destination}")" = "${source}" ]]; then
			return 0
		fi

		if [[ "${type}" = "file" ]] &&
			"${run_as[@]}" cmp -s "${source}" "${destination}"; then
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

#######################################
# Copies a file to the destination, making a backup of the original file in the
# process.
# Globals:
#   None
# Arguments:
#   Source: Source file
#   Destination: Destination path
#######################################
function ar::install_file {
	ar::__install_internal file false "$1" "$2"
}

#######################################
# Copies a file to the destination, making a backup of the original file in the
# process. With sudo.
# Globals:
#   None
# Arguments:
#   Source: Source file
#   Destination: Destination path
#######################################
function ar::install_file_el {
	ar::__install_internal file true "$1" "$2"
}

#######################################
# Symlinks a file to the destination, making a backup of the original file in
# the process.
# Globals:
#   None
# Arguments:
#   Source: Source file
#   Destination: Destination path
#######################################
function ar::install_symlink {
	ar::__install_internal symlink false "$1" "$2"
}

#######################################
# Symlinks a file to the destination, making a backup of the original file in
# the process. With sudo.
# Globals:
#   None
# Arguments:
#   Source: Source file
#   Destination: Destination path
#######################################
function ar::install_symlink_el {
	ar::__install_internal symlink true "$1" "$2"
}

#######################################
# Takes content as stdin, removes a block defined by arguments, and prints
# output
# Globals:
#   None
# Arguments:
#   Line number start
#   Line number end
#######################################
function ar::__remove_block {
	local is_segment_started=false
	while read -r line || [[ -n "${line}" ]]; do
		if [[ "$1" = "${line}" ]]; then
			is_segment_started=true
			continue
		fi
		if [[ "${is_segment_started}" = true ]]; then
			if [[ "$2" = "${line}" ]]; then
				is_segment_started=false
			fi
			continue
		fi
		echo "${line}"
	done <&0

	if [[ "${is_segment_started}" = true ]]; then
		ar::__lib_log error __remove_block "unexpected end of input"
		return 1
	fi
}

#######################################
# Internal ar::install_snippet logic
# Globals:
#   None
# Arguments:
#   Boolean whether to run as sudo or not
#   Destination file path
#   Header for section
#   Trailer for section
#######################################
function ar::__install_snippet_internal {
	local elevated=$1
	local destination=$2
	local block_string_start=$3
	local block_string_end=$4

	local run_as=()
	if [[ "${elevated}" = true ]]; then
		run_as=(sudo)
	fi

	# If file doesn't exist, create it
	if [[ ! -e "${destination}" ]]; then
		"${run_as[@]}" touch "${destination}"
	fi

	local scratchfile
	local temp_dir
	temp_dir=$(ar::mktemp)
	scratchfile="${temp_dir}/scratchfile"

	# TODO: Don't panic on symlinks that lead into $AR_DIR

	local remove_error=0
	ar::__remove_block "${block_string_start}" "${block_string_end}" \
		<"${destination}" |
		"${run_as[@]}" tee "${scratchfile}" >/dev/null &&
		"${run_as[@]}" mv "${scratchfile}" "${destination}" ||
		remove_error=1

	if [[ ${remove_error} == 1 ]]; then
		ar::__lib_log error __install_snippet_internal "either mv failed or \
ar::__remove_block failed"
		return 1
	fi

	# Write block_string_start
	echo "${block_string_start}" |
		"${run_as[@]}" tee -a "${destination}" >/dev/null

	# Write contents
	IFS=''
	while read -r line || [[ -n "${line}" ]]; do
		echo "${line}" | "${run_as[@]}" tee -a "${destination}" >/dev/null
	done <&0
	# Write block_string_end
	echo "${block_string_end}" | "${run_as[@]}" tee -a "${destination}" >/dev/null
	
	rm -r "${temp_dir}"
	return 0
}

#######################################
# Takes a (configuration) snippet with stdin and installs it into the
# destination file between the header and trailer.
# Globals:
#   None
# Arguments:
#   Destination file path
#   Header for section
#   Trailer for section
#######################################
function ar::install_snippet {
	ar::__install_snippet_internal false "$@" <&0
}

#######################################
# Takes a (configuration) snippet with stdin and installs it into the
# destination file between the header and trailer. Uses sudo for privilage
# elevation
# Globals:
#   None
# Arguments:
#   Destination file path
#   Header for section
#   Trailer for section
#######################################
function ar::install_snippet_el {
	ar::__install_snippet_internal true "$@" <&0
}

#######################################
# Download contents of URL to file using either curl or wget depending on which
# is available
# Globals:
#   None
# Arguments:
#   URL
#   Destination
#######################################
function ar::download {
	if [[ -x "$(command -v curl)" ]]; then
		curl -fsSL "$1" -o "$2"
		return $?
	elif [[ -x "$(command -v wget)" ]]; then
		wget -qo "$2" "$1"
		return $?
	fi
	ar::__lib_log error download \
		"failed to download \"$1\". curl or wget are unavailable"
	return 1
}

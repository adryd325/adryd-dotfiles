#!/usr/bin/env bash
# find AR_DIR
for dir in "${HOME}/.adryd" "${HOME}/.adrydnx" /opt/adryd-dotfiles; do
	if [[ -f "${dir}/.manifest" ]] && [[ "$(cat "${dir}/.manifest")" = "adryd-dotfiles-v8" ]]; then
		export AR_DIR="${dir}"
		break
	fi
done
# shellcheck source=../../lib.sh
source "${AR_DIR}/lib.sh"

function ar::prompt::exit_code_color() {
	if [[ ${ar_lastexit} -eq 0 ]]; then
		ar_prompt+="\[\e[1;32m\]"
		return
	fi
	ar_prompt+="\[\e[1;31m\]"
}

function ar::prompt::arrow() {
	if [[ "${TERM}" = "xterm-256color" ]] \
		|| [[ "${TERM}" = "alacritty" ]] \
		|| [[ -n ${container} ]]; then
		ar_prompt+="→"
		ar_ps2="→"
		return
	fi
	ar_prompt+="->"
	ar_ps2="->"
}

function ar::prompt::hostname() {
	if [[ -n "${SSH_CONNECTION}" ]] \
		|| [[ -n ${container} ]] \
		|| [[ -n ${SUDO_COMMAND} ]]; then
		ar_prompt+=" \[\e[34;1m\]\u@\H"
	fi
}

function ar::prompt::git() {
	local branch
	branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
	if [[ -n "${branch}" ]]; then
		local status
		status="$(git status 2>&1 | tee)"
		local bits
		grep "renamed:" &>/dev/null <<<"${status}" && bits+=">"
		grep "Your branch is ahead of" &>/dev/null <<<"${status}" && bits+="*"
		grep "new file:" &>/dev/null <<<"${status}" && bits+="+"
		grep "Untracked files" &>/dev/null <<<"${status}" && bits+="?"
		grep "deleted:" &>/dev/null <<<"${status}" && bits+="x"
		grep "modified:" &>/dev/null <<<"${status}" && bits+="!"
		if [[ -n "${bits}" ]]; then
			ar_prompt+=" \[\e[32m\]git:(\[\e[31m\]${branch}\[\e[32m\])\[\e[33m\]${bits}\[\e[0m\]"
		else
			ar_prompt+=" \[\e[32m\]git:(\[\e[31m\]${branch}\[\e[32m\])\[\e[0m\]"
		fi
	fi
}

function ar::prompt::newline() {
	ar_prompt_lastcmd_num="$(history 1 | cut -d " " -f3)"
	# shellcheck disable=SC2329
	ar::prompt::newline() {
		if [[ "${ar_prompt_lastcmd_num}" = "$(history 1 | cut -d " " -f3)" ]]; then
			ar_prompt+="\n"
			return
		fi
		local lastcmd
		lastcmd=$(history 1 | cut -d " " -f5-)
		ar_prompt_lastcmd_num="$(history 1 | cut -d " " -f3)"
		if [[ "${lastcmd}" = "reset" ]] || [[ "${lastcmd}" = "clear" ]]; then
			return
		fi
		ar_prompt+="\n"
	}
}

function ar::prompt() {
	ar_lastexit=$?

	# set window title
	# ar_prompt+="\[\e]2;\u@\H:\w\a\]"

	# always add an extra line after a command
	ar::prompt::newline
	ar::prompt::exit_code_color
	ar::prompt::arrow
	ar::prompt::hostname
	# dirname

	ar_prompt+="\[\e[36m\] \w"
	ar::prompt::git

	# finish prompt
	ar_prompt+="\[\e[0m\] "

	PS1="${ar_prompt}"
	PS2="${ar_ps2}"
	unset ar_prompt
	unset ar_ps2
	unset ar_lastexit
}

function ar::bashrc::has_path {
	mapfile -td ':' splitPath <<<"${PATH}"
	includes=1
	for path in "${splitPath[@]}"; do
		if [[ "${path}" = "$1" ]]; then
			includes=0
			break
		fi
	done
	return "${includes}"
}

function ar::bashrc::add_path_cond {
	if [[ -d "$1" ]] && ! ar::bashrc::has_path "$(realpath "$1")"; then
		PATH="$1:${PATH}"
	fi
}

function ar::bashrc::path {
	# normalize $PATH (useful for brew on macos)
	for dir in /bin /usr/bin /opt/local/bin /usr/local/bin ${HOME}/.local/bin ${AR_DIR}/bin; do
		ar::bashrc::add_path_cond "${dir}"
	done

	# Homebrew on macOS
	[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

	# nix multi-user on linux
	if ! ar::is_nixos && [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
		. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
	fi

	ar::bashrc::add_path_cond "${HOME}/.local/share/pnpm"
	ar::bashrc::add_path_cond "${HOME}/.cargo/bin"
	export PATH
}

function ar::bashrc::history {
	export HISTFILESIZE=50000
	export HISTSIZE=10000
	shopt -s histappend
	# Combine multiline commands into one in history
	shopt -s cmdhist
	# Ignore duplicates
	HISTCONTROL=ignoredups
	# Ignore ls without options and builtin commands
	export HISTIGNORE="&:ls:[bf]g:exit"
}

function ar::bashrc::aliases {
	[[ -x $(command -v xdg-open) ]] && alias open='xdg-open'
	[[ -x $(command -v yt-dlp) ]] && alias youtube-dl='yt-dlp'
	[[ -x $(command -v xclip) ]] && alias copy='xclip -selection clipboard'
	alias ls='ls --color=auto -v'
	alias la='ls --color=auto -vA'
	alias l='ls --color=auto -lahvF'
	alias sl='ls;echo slow down'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
}

function ar::bashrc::main {
	ar::bashrc::path
	# Only run when interactive
	if [[ $- = *i* ]]; then
		export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:"
		export EDITOR="nano"
		export VISUAL="nano"
		PROMPT_COMMAND="ar::prompt;history -a"

		# glob (*) selects files that begin with a dot too
		shopt -s dotglob

		# spell check
		shopt -s cdspell
		shopt -s dirspell

		ar::bashrc::history
		ar::bashrc::aliases

		# load bash completion
		# shellcheck source=/dev/null
		[[ -e "/usr/share/bash-completion/bash_completion" ]] && source /usr/share/bash-completion/bash_completion

	fi
}

ar::bashrc::main

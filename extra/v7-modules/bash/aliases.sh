#!/usr/bin/env bash

[[ -x $(command -v xdg-open) ]] && alias open='xdg-open'
[[ -x $(command -v yt-dlp) ]] && alias youtube-dl='yt-dlp'
[[ -x $(command -v xclip) ]] && alias copy='xclip -selection clipboard'
alias ls='ls --color=auto -v'
alias ll='ls --color=auto -alF'
alias la='ls --color=auto -A'
alias l='ls --color=auto -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
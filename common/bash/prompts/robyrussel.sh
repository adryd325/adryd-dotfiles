#!/usr/bin/env bash
__ar_prompt_exitCodeColor() {
    [[ ${__ar_prompt_exitCode} -eq 0 ]] && __ar_prompt+="\[\e[1;32m\]" && return
    __ar_prompt+="\[\e[1;31m\]"
}

__ar_prompt_arrow() {
    [[ "${TERM}" = "xterm-256color" ]] && __ar_prompt+="→" && __ar_ps2="→" && return
    __ar_prompt+="->"
    __ar_ps2="->"
}

__ar_prompt_ssh() {
    if [[ -n "${SSH_CONNECTION}" ]]; then
        __ar_prompt+=" \[\e[34;1m\]\u@\H"
    fi
}

__ar_prompt_git() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -n "${branch}" ]]; then
        local status
        status="$(git status 2>&1 | tee)"
        local bits
        echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null && bits+=">"
        echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null && bits+="*"
        echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null && bits+="+"
        echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null && bits+="?"
        echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null && bits+="x"
        echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null && bits+="!"
        if [[ -n "${bits}" ]]; then
            __ar_prompt+=" \[\e[32m\]git:(\[\e[31m\]${branch}\[\e[32m\])\[\e[33m\]${bits}\[\e[0m\]"
        else
            __ar_prompt+=" \[\e[32m\]git:(\[\e[31m\]${branch}\[\e[32m\])\[\e[0m\]"
        fi
    fi
}

__ar_build_prompt() {
    __ar_prompt_exitCode=$?
    # title
    __ar_prompt+="\[\e]2;\u@\H:\w\a\]"
    __ar_prompt_exitCodeColor
    __ar_prompt_arrow
    __ar_prompt_ssh
    # dirname
    __ar_prompt+="\[\e[36m\] \w"
    __ar_prompt_git
    # end prompt
    __ar_prompt+="\[\e[0m\] "
    PS1="${__ar_prompt}"
    PS2="${__ar_ps2}"
    __ar_prompt=""
}

PROMPT_COMMAND=__ar_build_prompt

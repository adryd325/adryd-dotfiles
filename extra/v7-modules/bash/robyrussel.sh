#!/usr/bin/env bash
__ar_prompt_exitCodeColor() {
    if [[ ${__ar_prompt_exitCode} -eq 0 ]]; then
        __ar_prompt+="\[\e[1;32m\]"
        return
    fi
    __ar_prompt+="\[\e[1;31m\]"
}

__ar_prompt_arrow() {
    if [[ "${TERM}" = "xterm-256color" ]] || [[ "${TERM}" = "alacritty" ]] || [[ -n ${container} ]]; then
        __ar_prompt+="→"
        __ar_ps2="→"
        return
    fi
    __ar_prompt+="->"
    __ar_ps2="->"
}

__ar_prompt_ssh() {
    if [[ -n "${SSH_CONNECTION}" ]] || [[ -n ${container} ]] || [[ -n ${SUDO_COMMAND} ]]; then
        __ar_prompt+=" \[\e[34;1m\]\u@\H"
    fi
}

__ar_prompt_git() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -n "${branch}" ]]; then
        local status
        status="$(git status 2>&1 | tee)"
        local bits
        grep "renamed:" &> /dev/null <<< "${status}" && bits+=">"
        grep "Your branch is ahead of" &> /dev/null <<< "${status}" && bits+="*"
        grep "new file:" &> /dev/null <<< "${status}" && bits+="+"
        grep "Untracked files" &> /dev/null <<< "${status}" && bits+="?"
        grep "deleted:" &> /dev/null <<< "${status}" && bits+="x"
        grep "modified:" &> /dev/null <<< "${status}" && bits+="!"
        if [[ -n "${bits}" ]]; then
            __ar_prompt+=" \[\e[32m\]git:(\[\e[31m\]${branch}\[\e[32m\])\[\e[33m\]${bits}\[\e[0m\]"
        else
            __ar_prompt+=" \[\e[32m\]git:(\[\e[31m\]${branch}\[\e[32m\])\[\e[0m\]"
        fi
    fi
}

__ar_prompt_newline() {
    __ar_prompt_lastcmd_num="$(history 1 | cut -d " " -f3)"
    __ar_prompt_newline() {
        if [[ "${__ar_prompt_lastcmd_num}" = "$(history 1 | cut -d " " -f3)" ]]; then
            # __ar_prompt+="\n"
            return
        fi
        local lastcmd
        lastcmd=$(history 1 | cut -d " " -f5-)
        __ar_prompt_lastcmd_num="$(history 1 | cut -d " " -f3)"
        if [[ "${lastcmd}" = "reset" ]] || [[ "${lastcmd}" = "clear" ]]; then
            return
        fi
        __ar_prompt+="\n"
    }
}

__ar_build_prompt() {
    __ar_prompt_exitCode=$?
    __ar_prompt_newline
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

#!/usr/bin/env bash
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
    [[ -n "${AR_MODULE}" ]] && logString+="\x1b[35m${AR_MODULE}\x1b[0m "
    [[ -n "${AR_LOG_PREFIX:=}" ]] && logString+="\x1b[32m(${AR_LOG_PREFIX})\x1b[0m "
    logString+="${*:2}"
    [[ -z ${AR_LOGLEVEL:=} ]] && AR_LOGLEVEL=2
    [[ ${logLevel} -lt ${AR_LOGLEVEL} ]] && [[ ${logLevel} -lt 5 ]] && return
    echo "${echoArgs}" "${logString}"
}

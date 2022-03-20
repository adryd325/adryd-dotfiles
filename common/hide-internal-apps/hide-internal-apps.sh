#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
source ../../lib/log.sh
AR_MODULE="hide-internal-apps"

function hideApp() {
    app="$1"
    if [[ -f "${app}" ]] && ! grep -l "NoDisplay=true" "${app}" > /dev/null; then
        log silly "Hiding ${app} from apps menu"
        echo "NoDisplay=true" | sudo tee -a "${app}" > /dev/null
    fi
}

source ./application-list.sh
log info "Hiding internal apps"
for appDir in "${appDirs[@]}"; do
    for app in "${apps[@]}"; do
        hideApp "${appDir}"/"${app}"
    done
    for appGlob in "${appGlobs[@]}"; do
        for app in "${appDir}"/${appGlob}; do
            hideApp "${app}"
        done
    done
done

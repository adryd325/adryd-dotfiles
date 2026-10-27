#!/usr/bin/env bash
source ./constants.sh
source ./package-list.sh

sudo pacman -Syyu --noconfirm

oldBuiltList=$(pacman -Slq "${REPO_NAME}")
for package in ${oldBuiltList}; do
    includes=false
    for curPackage in "${PACKAGE_LIST[@]}"; do
        if [[ "${curPackage}" = "${package}" ]]; then
            includes=true
        fi
    done
    if [[ ${includes} = false ]]; then
        repo-remove "${REPO_ROOT}/${REPO_NAME}.db.tar.zst" "${package}"
        paccache -rc "${REPO_ROOT}" -k0 "${package}"
    fi
done

for key in "${KEYS_TRUST[@]}"; do
    gpg --recv-keys "${key}"
done

failed=()
for package in "${PACKAGE_LIST[@]}"; do
    echo =======================
    echo =======================
    echo =======================
    echo "NOW BUILDING: ${package}"
    echo "BUILDS FAILED (if any): ${failed[*]}"
    echo =======================
    echo =======================
    echo =======================
    aur sync --pkgver --sign -A --noconfirm --nocheck --noview --remove --no-ver-argv --database "${REPO_NAME}" --root "${REPO_ROOT}" "${package}" > >(tee "/var/aur/logs/${package}.stdout.log") 2> >(tee "/var/aur/logs/${package}.stderr.log" >&2) || failed+=("${package}")
    sleep 5
done

paccache -rc "${REPO_ROOT}" -k2

if [[ ${#failed[@]} -ne 0 ]]; then
    echo "The following packages failed to build: ${failed[*]}"
fi

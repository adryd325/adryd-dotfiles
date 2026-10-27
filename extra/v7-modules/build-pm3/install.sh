#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="build-pm3"

repoDir="${HOME}/_/proxmark3"
currentVersion="d957b23f9abcbe61b81ad5f765b90bf38a0588a5"

case "$(ar_get_distro)" in
"fedora")
    log info Installing dependencies
    sudo dnf install -y git make gcc gcc-c++ arm-none-eabi-gcc-cs arm-none-eabi-newlib \
        readline-devel bzip2-devel lz4-devel qt5-qtbase-devel bluez-libs-devel \
        python3-devel libatomic openssl-devel gd-devel
    ;;
*)
    echo "module is not yet supported on this os"
    exit 1
    ;;
esac

if [[ ! -d "${repoDir}" ]]; then
    git clone https://github.com/RfidResearchGroup/proxmark3 "${repoDir}"
    (
        cd "${repoDir}" || exit 1
        git checkout "${currentVersion}"
    )

else
    (
        cd "${repoDir}" || exit 1
        git pull origin master
    )
fi

if [[ -d "${repoDir}" ]]; then
    cp ./Makefile.platform "${repoDir}/Makefile.platform"
fi

(
    cd "${repoDir}" || exit 1
    make clean
    make -j2
    sudo make install
) || exit 1

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib.sh
AR_MODULE="build-sdrpp"

repoDir="${HOME}/_/sdrpp"

case "$(ar_get_distro)" in
"fedora")
    log info Installing dependencies
    sudo dnf install -y fftw-devel volk-devel libzstd-devel glfw-devel rtaudio-devel rtl-sdr-devel libusb1-devel libtalloc-devel libmnl-devel liburing-devel libosmocore-devel airspyone_host airspyone_host-devel hackrf-devel
    ;;
*)
    echo "module is not supported on this os"
    exit 1
    ;;
esac

if [[ ! -d "${repoDir}" ]]; then
    git clone https://github.com/AlexandreRouma/SDRPlusPlus "${repoDir}"
fi

buildOpts=(-DOPT_BUILD_AIRSPYHF_SOURCE=off -DOPT_BUILD_BLADERF_SOURCE=off -DOPT_BUILD_FOBOSSDR_SOURCE=off -DOPT_BUILD_HACKRF_SOURCE=on -DOPT_BUILD_PLUTOSDR_SOURCE=off -DOPT_BUILD_DISCORD_PRESENCE=off)

# buildOpts+=("-DOPT_BUILD_AIRSPY_SOURCE=off")
buildOpts+=("-DOPT_BUILD_SDRPLAY_SOURCE=off")

(
    cd "${repoDir}" || exit 1
    git pull
    rm -rf build
    mkdir build
    cd build || exit 1
    echo "${buildOpts[@]}"
    cmake .. "${buildOpts[@]}" || exit 1
    make -j || exit 1
    sudo make install
    ar_install_symlink_el /usr/lib/sdrpp /usr/lib64/sdrpp
) || exit 1

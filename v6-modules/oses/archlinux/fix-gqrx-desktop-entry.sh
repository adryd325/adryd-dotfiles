#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
export AR_MODULE="fix-gqrx-desktop-entry"

log info "Fixing gqrx desktop entry"
sudo tee /usr/share/applications/gqrx.desktop >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Gqrx
GenericName=Software Defined Radio
Comment=Software defined radio receiver implemented using GNU Radio and the Qt GUI toolkit
# FIXME add comments in other languages
GenericName[ru]=Программно-определённое радио
Comment[ru]=Приемник для программно-определенного радио (SDR) использующий GNU Radio и библиотеку Qt.
GenericName[nl]=Software Defined Radio
Comment[nl]=Software defined radio ontvanger geïmplementeerd met GNU Radio en de Qt GUI toolkit
Comment[de]=Software defined Radio auf Basis von GNU Radio und dem Qt GUI Toolkit
GenericName[zh_CN]=软件无线电
Comment[zh_CN]=使用 GNU Radio 和 Qt GUI 实现的软件无线电接收器
Exec=gqrx
Terminal=false
Icon=gqrx
Categories=AudioVideo;Audio;Qt;HamRadio;
Keywords=SDR;Radio;HAM;
EOF

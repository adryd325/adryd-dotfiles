#!/usr/bin/env bash
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${UID}/bus
export XDG_RUNTIME_DIR=/run/user/${UID}
export DISPLAY=:0
/run/wrappers/bin/op read "$1"

#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
AR_MODULE="optimus"

# Make sure we have gdm, or something that provides gdm
if pacman -Q gdm &>/dev/null; then
    log info "Disable Wayland"
    # Backup existing config
    [[ ! -e /etc/gdm/custom.conf.orig ]] &&
        sudo cp /etc/gdm/custom.conf /etc/gdm/custom.conf.orig
    sudo sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf
    # The logs are rather self-explainatory so no need for more comment
    log info "Setting power management kernel option"
    echo 'options nvidia "NVreg_DynamicPowerManagement=0x02"' | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
    log info "Setting udev rules"
    sudo tee /etc/udev/rules.d/80-nvidia-pm.rules >/dev/null <<EOF
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
# Commented out cause this causes volume to change when unplugging my laptop
# They also seem to have been removed from the arch wiki so I'm not sure how necesary they are
# ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF
    if pacman -Q switcheroo-control &>/dev/null; then
        log info "Enable switcheroo-control"
        sudo systemctl enable switcheroo-control
    fi
    if pacman -Q nvidia-utils &>/dev/null; then
        log info "Enable switcheroo-control"
        sudo systemctl enable nvidia-persistenced
    fi
fi

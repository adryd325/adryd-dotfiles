#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../../lib/log.sh
source ../../lib/os.sh
[[ "${USER}" = "root" ]] && log error "Do not run as root" && exit 1

../../common/bash/_install.sh
../../common/bash/_install.sh globalInstall

sudo apt-get update
sudo apt-get upgrade -y
ensureInstalled git direnv rtl-sdr gr-osmosdr gqrx-sdr nodejs npm vlc dnsmasq hostapd netfilter-persistent iptables-persistent zip unzip

../../common/nix.sh --daemon
../../common/nixpkgs/_install.sh

mkdir -p "${HOME}/_"

../../workspaces/telive/_install.sh
../../workspaces/tetra-kit/_install.sh

lockStr="## adryd-dotfiles-lock (tetra)"
if ! grep "^${lockStr}" /etc/dhcpcd.conf &>/dev/null; then
    log info "Installing dhcpcd config"
    sudo tee -a /etc/dhcpcd.conf &>/dev/null <<EOF
${lockStr}
interface eth0
    static ip_address=10.142.0.21/24
    static routers=10.142.0.1
    static domain_name_servers=10.142.0.1 8.8.8.8

interface wlan0
    static ip_address=10.142.21.1/24
    nohook wpa_supplicant
EOF
fi

if ! grep "^${lockStr}" /etc/dnsmasq.conf &>/dev/null; then
    log info "Installing dnsmasq config"
    sudo tee -a /etc/dnsmasq.conf &>/dev/null <<EOF
${lockStr}
dhcp-range=10.142.21.10,10.142.21.50,255.255.255.0,12h
interface=wlan0 # Listening interface
domain=wlan
address=/gw.wlan/10.142.21.1
EOF
fi

log info "Installing hostapd config"
sudo tee /etc/hostapd/hostapd.conf &>/dev/null <<EOF
country_code=CA
interface=wlan0
driver=nl80211
ssid=TETRA
channel=7
hw_mode=g
wme_enabled=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=412962500
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
# Yes the password is public, if you somehow happen to run into me in public you deserve to get to listen to the audio stream...

log info "Enabling (but not starting) hostapd"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

log info "Enabling routing"
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo netfilter-persistent save
sudo tee /etc/sysctl.d/routed-ap.conf >/dev/null <<<"net.ipv4.ip_forward=1"

log info "Enabling VNC server"
sudo systemctl enable --now vncserver-x11-serviced

log info "Enabling SSH"
sudo systemctl enable --now ssh

log info "Ensuring dvb_usb_rtl28xxu is disabled"
sudo tee /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf >/dev/null <<<"blacklist dvb_usb_rtl28xxu"

log info "Installing tetra-autostart script"
sudo cp -f ./tetra-autostart.desktop /etc/xdg/autostart/tetra-autostart.desktop

log tell "Next steps:"
log tell " - nix-copy-closure from oracle-arm-toronto-1.vm.origin.adryd.com"
log tell " - Start hostapd"
log tell "Using:"
log tell " - Enable VNC for connectivity on a cell phone"
log tell " - Use SSH with X forwarding when connecting from Linux"
log tell " - Run telive or sdrtrunk from a terminal to get started"

## TODO
## connman unblock after apt update
## use vncauth instead of whatever realvnc uses
## set default screen resolution

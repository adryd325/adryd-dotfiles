#!/usr/bin/env bash

packages=(
    # Base
    "linux"
    "linux-firmware"
    "linux-headers"
    "intel-ucode"
    "base"
    "base-devel"
    "man-db"
    "man-pages"
    "paru"
    "btrfs-progs"
    "networkmanager"
    "sudo"
    "nano"
    "git"
    "pacman"
    "openssh"

    # Drivers
    "nvidia"
    "nvidia-lts"
    "nvidia-prime"
    "nvidia-settings"
    "nvidia-utils"
    #"lib32-nvidia-utils" # Needed for steam runing with dedicated gpu
    "vulkan-intel"
    #"lib32-vulkan-intel"
    "intel-media-driver"
    "cuda"
    "fprintd"

    # Extra kernel
    "linux-lts"
    "linux-lts-headers"

    # Gnome DE
    "gdm"
    "gnome-session"
    "gnome-shell"

    # Gnome essentials
    "gnome-console"
    "gnome-control-center"
    "gnome-software"
    "gnome-text-editor"
    "nautilus"
    "firefox"

    # Gnome services
    "gnome-backgrounds"
    "gnome-color-manager"
    "gnome-menus"
    "gnome-shell-extensions"
    "gnome-settings-daemon"
    "gnome-browser-connector"
    "malcontent"
    "system-config-printer"
    "gvfs"
    gvfs-{afc,gphoto2,nfs,smb}
    "orca"
    "sushi" # file preview
    "xdg-desktop-portal-gnome"
    "xdg-user-dirs-gtk"
    gnome-bluetooth-3.0
     gst-plugins-good
     gst-plugin-pipewire
     gst-plugins-bad
     gst-plugin-openh264
     gstreamer-vaapi
     "switcheroo-control"
     usbguard

    # Gnome apps
    "baobab"
    "evince"
    "file-roller"
    "gnome-calculator"
    "gnome-calendar"
    "gnome-clocks"
    "gnome-connections"
    "gnome-contacts"
    "gnome-disk-utility"
    "gnome-font-viewer"
    "gnome-keyring"
    "gnome-logs"
    "gnome-system-monitor"
    "gnome-weather"
    "simple-scan"
    "snapshot"
    "loupe"
    "totem"

    # Programming languages and libs
    "jdk-openjdk"
    "jdk17-openjdk"
    "jdk11-openjdk"
    "jdk8-openjdk"
    "nodejs"
    "npm"
    "prettier"
    "eslint"
    "pnpm"
    "python"
    "python-pip"
    "rustup"

    # Desktop apps
    "thunderbird"
    "visual-studio-code-bin"
    "1password"
    "obs-studio"
    "dconf-editor"
    "kcharselect" # better unicode char map
    "veracrypt" # multiplatform drive encryption tool
    "mpv"
    "jetbrains-toolbox"
    "obsidian"
    "libreoffice-fresh"
    "prismlauncher"
    "xournalpp"
    "helvum"
    "gimp"
    "aseprite"
    "inkscape"
    "signal-desktop"
    "telegram-desktop"
    # alt browsers
    "chromium"
    "torbrowser-launcher"

    # Misc
    "plymouth"
    "polkit"
    "v4l2loopback-dkms"
    "acpi_call-dkms"
    "flatpak"
    "aria2"
    "bash-completion"
    "borg"
    "croc"
    "cups"
    "hplip"
    "direnv"
    "electron"
    "espeak-ng"
    "fwupd"
    "git-crypt"
    "htop"
    "jq"
    "gamemode"
    "mesa-utils"
    "mesa-demos"
    "neofetch"
    "shellcheck"
    "strace"
    "perl-authen-sasl" # git-send-email
    "perl-io-socket-ssl" # git-send-email
    "touchegg"
    "intel-gpu-tools"
    "screen"
    "google-cloud-cli"
    "caddy"
    "usbutils"
    "xclip"
    "xorg-xkill"
    # performance and battery
    "powertop"
    "tlp"
    "throttled"
    # pacman stuff
    "pacman-contrib"
    "reflector"
    "pkg_scripts"
    # coreutils clones
    "the_silver_searcher" # command: ag. used to find text contents of files with minimal syntax
    # archival and fs stuff
    "unzip"
    "zip"
    "p7zip"
    "cdrtools" # Make isos, does a lot more but felt it fit here
    "ntfs-3g"
    "exfatprogs"
    # multimedia
    "ffmpeg"
    "yt-dlp"
    "imagemagick"
    "gifski"
    # build tools frequently pulled when compiling on the aur
    "cmake"
    "meson"
    "ninja"
    # audio
    pipewire{,-pulse,-alsa}
    alsa-utils
    noise-suppression-for-voice
    rtaudio
    # virtualization
    "virt-viewer"
    "virt-manager"
    "qemu-desktop"
    "qemu-emulators-full"
    "qemu-user-static"
    "qemu-user-static-binfmt"
    "dnsmasq" # dns server, needed for vm stuff so in this category
    "edk2-ovmf"
    "edk2-aarch64"
    "swtpm" # virtual TPM
    # network
    "inetutils" # includes drill
    "mtr"
    "nmap"
    "bind" # includes dig
    "openbsd-netcat" # open tcp sockets to anything
    "whois"
    "traceroute"
    "edk2-shell"
    "mitmproxy"
    # wine
    wine-{gecko,mono,staging}

    # Fonts
    "cantarell-fonts" # Cantarell
    "inter-font" # Inter
    "gsfonts" # Nimbus Roman
    noto-fonts{,-cjk,-emoji}
    "ttf-unifont" # Unifont
    # "ttf-ipa-mona"
    "ttf-ms-fonts"
    "ttf-ibm-plex"
    "otf-san-francisco-mono"
    "ocr-fonts"
    "ttf-roboto"

    # Network uhh
    "mullvad-vpn"
    "nm-connection-editor"
    "wireguard-tools"
    "systemd-resolvconf"

    # Theming
    "adw-gtk3-git" # Make all gtk3 apps look like libadwaita
    # "qt5ct" # Make QT apps not look awful

    # proxmark3 deps
    "ccache"
    "readline"
    "bzip2"
    "arm-none-eabi-gcc"
    "arm-none-eabi-newlib"
    "qt5-base"
    "bluez"

    # SDR stuff
    libsdrplay
    gqrx
    soapysdrplay3-git
    #"kalibrate-rtl-git"
    #"x11vnc" # For controlling laptop from phone
    #"vlc" # provides an easy way of broadcasting audio via http

    # Radio stuff
    # "qdmr"
    # "spi-ch341-usb-dkms"
    # "chirp-hg"

    # Disassembling java stuff
    #"jadx" # convert the weird apk java thing to something human readable
    #"recaf" # java bytecode editor
)

flatpaks=(
    #"net.blockbench.Blockbench"
    #"uk.co.powdertoy.tpt"
    "com.github.tchx84.Flatseal"
    "re.sonny.Junction"
    "com.belmoussaoui.Obfuscate"
    "org.gnome.SoundRecorder"
    "com.yubico.yubioath"
    "com.spotify.Client"
    "com.slack.Slack"
    "com.raggesilver.BlackBox"
    "im.riot.Riot"
    "org.localsend.localsend_app"
    "org.gnome.Solanum"
    "com.usebottles.bottles"
)

export packages
export flatpaks
export flatpaksGnomeNightly

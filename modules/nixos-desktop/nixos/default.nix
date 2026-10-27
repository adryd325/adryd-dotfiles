{
  inputs,
  pkgs,
  username,
  ar_dir,
  modulesPath,
  ...
}:
{
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  imports = [
    inputs.laminix.nixosModules.default
    "${modulesPath}/installer/scan/not-detected.nix"
    "${ar_dir}/modules/nixos-desktop/nixos/services/syncthing.nix"
    "${ar_dir}/modules/nixos-desktop/nixos/services/borg/default.nix"
  ];

  environment.laminix.enable = true;

  networking.networkmanager.enable = true;

  programs.nix-ld.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 13337;
        to = 13340;
      }
    ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      timeout = 5;
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot = {
        enable = true;
      };
    };
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    nixfmt
    discord
    parsec-bin
    telegram-desktop
    signal-desktop
    virt-viewer
    vscode
    htop
    obsidian
    qbittorrent
    tor-browser
    kdePackages.dolphin
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.qtsvg
    kdePackages.kcharselect
    kdePackages.ark
    pavucontrol
    wireshark
    helvum
    libreoffice
    # inkscape
  ];

  programs.nh = {
		enable = true;
		clean = {
			enable = true;
			extraArgs = "--keep 5 --keep-since 3d";
		};
		flake = "${ar_dir}/nix";
	};


  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "${username}" ];
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  virtualisation.docker = {
    enable = true;
  };

  programs.firefox.enable = true;
  programs.chromium.enable = true;

  programs.appimage = {
    enable = false;
    binfmt = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      "docker"
    ];
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = false;
      keep-outputs = false;

      substituters = [ ];
      trusted-public-keys = [ ];
    };

    optimise = {
      automatic = true;
      dates = [ "03:00" ];
    };

    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  # rtkit allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji
    terminus_font
    terminus_font_ttf
    unifont
    corefonts
  ];

  environment.extraInit = ''
  export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
'';

  services = {
    # avahi required for service discovery
    avahi.enable = true;

    printing.enable = true;
    fprintd.enable = true;
    gpm.enable = true;
    flatpak.enable = true;
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "${username}" ];
        MaxAuthTries = 4;
        PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
      };
    };

    tuned.enable = true;

    pipewire = {
      enable = true;

      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;

      # opens UDP ports 6001-6002
      raopOpenFirewall = true;

      extraConfig.pipewire = {
        "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";

              # increase the buffer size if you get dropouts/glitches
              # args = {
              #   "raop.latency.ms" = 500;
              # };
            }
          ];
        };
      };
    };

  };
}

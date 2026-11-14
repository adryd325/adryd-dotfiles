{ pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Bare minimum packages
  environment.systemPackages = with pkgs; [
    nano
    curl
    git
  ];

  system.stateVersion = "changeme";
}

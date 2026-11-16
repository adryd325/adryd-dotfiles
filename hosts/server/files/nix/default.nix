{
  ar_dir,
  modulesPath,
  ...
}:
{
  system.stateVersion = "26.05";
  networking.hostName = "files";

  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./services/dnsmasq.nix
    ./services/syncthing.nix
    ./services/samba.nix
  ];

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  users.users."data" = {
    uid = 9999;
    isNormalUser = true;
    description = "data";
    extraGroups = [
      "data"
    ];
  };

  users.groups."data" = {
    gid = 9999;
  };
}

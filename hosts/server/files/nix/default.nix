{
  ar_dir,
  modulesPath,
  ...
}:
{
  system.stateVersion = "26.05";
  networking.hostName = "files-nixmigrate";

  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  networking.firewall = {
    allowedTCPPorts = [ 69 ];
    allowedUDPPorts = [ 69 ];
  };

  services.dnsmasq = {
    enable = true;

    # prevent dnsmasq from breaking resolved
    # https://github.com/NixOS/nixpkgs/blob/f1e5c356f35d07e7b71a6b5e6c9338e0b029e0c0/nixos/modules/system/boot/resolved.nix#L209
    resolveLocalQueries = false;

    settings = {
      # we're not actually using the dns server, and it gets into a fight with
      # systemd-resolved over the port
      port = 0;
      listen-address = "0.0.0.0";
      bind-interfaces = true;
      enable-tftp = true;
      tftp-root = "/mnt/data/tftp";
    };
  };
}

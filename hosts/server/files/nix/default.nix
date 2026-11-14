{
  ar_dir,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    "${ar_dir}/modules/nixos-common/default.nix"
  ];
  networking.hostName = "files-nixmigrate";

  services.dnsmasq = {
    enable = true;
    settings = {
      # we're not actually using the dns server, and it gets into a fight with
      # presumably systemd.resolved over the port
      port = 5353;
      enable-tftp = true;
      tftp-root = "/mnt/data/tftp";
    };
  };

  system.stateVersion = "26.05";
}

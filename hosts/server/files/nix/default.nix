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
    # configFile = ''
    #   enable-tftp
    #   tftp-root=/mnt/data/tftp
    # '';
  };

  system.stateVersion = "26.05";
}

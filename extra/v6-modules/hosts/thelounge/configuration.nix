{ config, pkgs, ... }:

{
  imports = [ /opt/adryd-dotfiles/oses/nixos/lxc-container.nix /opt/adryd-dotfiles/oses/nixos/common.nix ];

  networking = {
    hostName = "thelounge";
    interfaces.eth0.ipv4.addresses = [{
      address = "10.142.0.114";
      prefixLength = 24;
    }];
    firewall.allowedTCPPorts = [ 9000 ];
  };

  services.thelounge.enable = true;
}

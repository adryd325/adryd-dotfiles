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
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 69 ];
    allowedUDPPorts = [ 69 ];
  };

  users.users."data" = {
    uid = 9999;
    isNormalUser = true;
    description = "data";
  };

  users.groups."data" = {
    uid = 9999;
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

  # MANUAL INTERVENTION: Must set samba password with `smbpasswd -a data`
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "files";
        "netbios name" = "files";
        "security" = "user";
        "use sendfile" = "yes";
        # set if windows xp wont talk to it
        # "min protocol" = "NT1";
        "hosts allow" = "10.142.0. 10.142.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        # Prevent unauthorised users from viewing shares
        "access based share enum" = "yes";
      };
      "private" = {
        "path" = "/mnt/data";
        "comment" = "files on lemon";
        "hide unreadable" = "yes";
        "read only" = "no";
        "writable" = "yes";
        "browseable" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "guest ok" = "no";
        "force user" = "data";
        "force group" = "data";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}

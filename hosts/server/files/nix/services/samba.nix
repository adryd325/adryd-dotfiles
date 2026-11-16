{
  # MANUAL INTERVENTION: Must set samba password with `smbpasswd -a data`
  services.samba = {
    enable = true;
    openFirewall = true;
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
      "data" = {
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

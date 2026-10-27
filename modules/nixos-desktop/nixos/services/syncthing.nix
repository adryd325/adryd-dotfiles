# MANUAL INTERVENTION: Must update device IDs, change keys and accept sync folders
# MANUAL INTERVENTION: Must be connected to lemon VPN
# TODO: Centralize device IDs definition
{ username, ... }: {
  systemd.targets.multi-user.wants = [ "syncthing@${username}.service" ];
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    systemService = false;
    settings = {
      devices = {
        "framework-13".id = "E42ASWH-ZJWKXPS-65ALTV3-V6OQQCA-B2C7EJL-H6PAVNG-QKSTFLO-7QNY6A4";
        "files".id = "OKH55VD-25WFIZE-7LKRMAF-MQGKJSL-DN2SX7R-VOHDNIR-C7F7WDI-IJF7QAU";
      };
      folders = {
        "mprod" = {
          path = "/home/${username}/_/mprod";
          devices = [
            "framework-13"
            "files"
          ];
        };
        "svgs" = {
          path = "/home/${username}/_/svgs";
          devices = [
            "framework-13"
            "files"
          ];
        };
        "3d_projects" = {
          path = "/home/${username}/_/3d_projects";
          devices = [
            "framework-13"
            "files"
          ];
        };
      };
    };
  };
}

# MANUAL INTERVENTION: Must update device IDs, change keys and accept sync folders
# MANUAL INTERVENTION: Must set a GUI password after deploy
# TODO: Centralize syncthing definition
{
  networking.firewall = {
    allowedTCPPorts = [ 8384 ];
  };

  systemd.targets.multi-user.wants = [ "syncthing@data.service" ];

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    systemService = false;
    guiAddress = "0.0.0.0:8384";
    settings = {
      devices = {
        "framework-13".id = "E42ASWH-ZJWKXPS-65ALTV3-V6OQQCA-B2C7EJL-H6PAVNG-QKSTFLO-7QNY6A4";
        "files".id = "QARP7UB-44GHWXM-CENDNUG-YEKH7VD-WGZLSMH-FO6HF26-WDSP675-6J2Y7AI";
      };
      folders = {
        "mprod" = {
          path = "/mnt/data/mprod";
          devices = [
            "framework-13"
            "files"
          ];
        };
        "svgs" = {
          path = "/mnt/data/svgs";
          devices = [
            "framework-13"
            "files"
          ];
        };
        "3d_projects" = {
          path = "/mnt/data/3d_projects";
          devices = [
            "framework-13"
            "files"
          ];
        };
      };
    };
  };
}

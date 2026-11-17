# MANUAL INTERVENTION: Must update device IDs, change keys and accept sync folders
# MANUAL INTERVENTION: Must set a GUI password after deploy
# TODO: Centralize syncthing definition
{
  networking.firewall = {
    allowedTCPPorts = [ 8384 ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    systemService = true;
    guiAddress = "0.0.0.0:8384";
    user = "data";
    settings = {
      devices = {
        "framework-13".id = "K3UUY5R-RHUMWZZ-TVE3TP4-AVGKEED-3EIB5UR-TUYUMXN-KAYIOXB-Y7UOPAL";
        "files".id = "XUBIHUH-TZSUAUL-TA5AOWG-JIN6TES-UQY2RGQ-34SSLOD-K76RLNQ-SBTMRQV";
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

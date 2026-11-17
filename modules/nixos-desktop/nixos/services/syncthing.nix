# MANUAL INTERVENTION: Must update device IDs, change keys and accept sync folders
# MANUAL INTERVENTION: Must be connected to lemon VPN
# TODO: Centralize device IDs definition
{ username, ... }: {

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "${username}";
    group = "users";
    configDir = "/home/${username}/.config/syncthing";
    settings = {
      devices = {
        "framework-13".id = "K3UUY5R-RHUMWZZ-TVE3TP4-AVGKEED-3EIB5UR-TUYUMXN-KAYIOXB-Y7UOPAL";
        "files".id = "XUBIHUH-TZSUAUL-TA5AOWG-JIN6TES-UQY2RGQ-34SSLOD-K76RLNQ-SBTMRQV";
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

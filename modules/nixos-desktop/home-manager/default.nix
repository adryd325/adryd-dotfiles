{
  pkgs,
  lib,
  self,
  system,
  ...
}:
let
  mkEntry = (
    branch: discordName: {
      name = "Moonlight ${discordName}";
      exec = "${lib.getExe' self.packages.${system}.moonlight-launcher "moonlight-${branch}"} %U";
      icon = "discord";
      comment = "Moonlight for Discord ${discordName}";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      settings = {
        StartupWMClass = "moonlight-${lib.toLower discordName}";
      };
    }
  );
in
{
  xdg.desktopEntries = {
    moonlight = mkEntry "stable" "Stable";
  };
}

{
  username,
  ar_dir,
  self,
  inputs,
  config,
  system,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
      inherit
        inputs
        self
        username
        ar_dir
        ;

      system = system;
      host = config.networking.hostName;
      os_config = config;

      user = config.home-manager.users.${username};
      home = config.home-manager.users.${username}.home.homeDirectory;
    };

    users.${username} = {
      home.stateVersion = "26.05";
      imports = [
        "${ar_dir}/modules/nixos-desktop/home-manager/default.nix"
      ];
    };
  };
}

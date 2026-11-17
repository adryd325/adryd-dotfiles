{ username, ar_dir, self, inputs... }: {

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

      host = config.networking.hostName;
      os_config = config;

      user = config.home-manager.users.${username};
      home = config.home-manager.users.${username}.home.homeDirectory;
    };

    users.${username} = {
      imports = [
        "${ar_dir}/modules/nixos-desktop/home-manager/default.nix"
      ];
    };
  };
}

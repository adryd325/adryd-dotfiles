{
  description = "base flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    laminix = {
      url = "github:jackboykin/laminix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager = {
    # 	url = "github:nix-community/home-manager";
    # 	inputs.nixpkgs.follows = "nixpkgs";
    # };
    # moonlight = {
    # 	url = "github:moonlight-mod/moonlight/main";
    # 	inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    { self, nixpkgs, laminix, stylix }@inputs:
    let
      baseSystem = {
        args = {
          inherit inputs;

          username = "adryd";
          ar_dir = toString ./..;
        };

        modules = [
          inputs.laminix.nixosModules.default
          inputs.stylix.nixosModules.stylix
        ];
      };
    in
    {
      nixosConfigurations."framework-13" = nixpkgs.lib.nixosSystem rec { 
        specialArgs = baseSystem.args;
				system = "x86_64-linux";
        modules = baseSystem.modules ++ [
					./allowUnfree.nix
          ../hosts/desktop/framework-13/nix/default.nix
        ];
      };
    };
}

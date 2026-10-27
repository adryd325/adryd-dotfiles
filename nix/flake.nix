{
  description = "base flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    laminix = {
      url = "github:jackboykin/laminix";
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
    { self, nixpkgs, laminix }@inputs:
    let
      baseSystem = {
        args = {
          inherit inputs;

          username = "adryd";
          ar_dir = toString ./..;
        };

        modules = [

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

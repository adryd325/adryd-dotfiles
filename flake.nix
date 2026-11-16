{
  description = "adryd-dotfiles v8";
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

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      # TODO: turn this into a function
      baseSystem = {
        args = {
          inherit inputs;
          self = self;
          system = "x86_64-linux";
          username = "adryd";
          ar_dir = toString ./.;
        };

        modules = [
          inputs.laminix.nixosModules.default
          inputs.stylix.nixosModules.stylix
          ({ pkgs, ... }: {
            time.timeZone = "America/Toronto";
            i18n.defaultLocale = "en_CA.UTF-8";

            # Bare minimum packages
            environment.systemPackages = with pkgs; [
              nano
              curl
              git
            ];

            nixpkgs.config.allowUnfree = true;

            nix.settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
          })
        ];
      };

      inherit (self.lib.systems) forAllSystems;
      inherit (self.lib.hosts) mkHosts;
    in
    {
      lib = import ./nix/lib {
        inherit inputs;
        inherit (nixpkgs) lib;
      };

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      packages = forAllSystems (
        { pkgs, system, ... }: {
          moonlight-launcher = pkgs.callPackage ./nix/packages/moonlight-launcher {
            fenix = inputs.fenix.packages."${system}";
          };
        }
      );

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            git
            nano
            curl
          ];
        };
      });

      nixosConfigurations."framework-13" = nixpkgs.lib.nixosSystem rec {
        specialArgs = baseSystem.args;
        system = "x86_64-linux";
        modules = baseSystem.modules ++ [
          ./hosts/desktop/framework-13/nix/default.nix
        ];
      };

      nixosConfigurations."files-nixosmigrate" = nixpkgs.lib.nixosSystem rec {
        specialArgs = baseSystem.args;
        system = "x86_64-linux";
        modules = baseSystem.modules ++ [
          ./hosts/server/files/nix/default.nix
        ];
      };
    };
}

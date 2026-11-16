# Shamelessly stolen from marsh https://github.com/marshift/flake/blob/2026/lib/systems.nix
{
  inputs,
  lib,
}:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    # "x86_64-darwin"
    "aarch64-darwin"
  ];

  forAllSystems =
    fn: lib.attrsets.genAttrs systems (system: fn inputs.nixpkgs.legacyPackages.${system});
in
{
  inherit systems forAllSystems;
}

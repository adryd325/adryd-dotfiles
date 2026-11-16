{
  inputs,
  lib,
}:
{
  systems = import ./systems.nix { inherit inputs lib; };
}

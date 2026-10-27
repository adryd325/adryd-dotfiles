{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    croc
  ];
}

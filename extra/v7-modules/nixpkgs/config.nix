{
  permittedInsecurePackages = [
    "python-2.7.18.6"
    "python2.7-Pillow-6.2.2"
  ];
  nixpkgs.overlays = [
      (import ~/.config/nixpkgs/overlays/adryd-dotfiles/default.nix)
    ];
  allowUnfree = true;
}

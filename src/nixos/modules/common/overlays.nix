# 
# This file centrally handles al the overlays
#
{
  pkgs,
  inputs,
  ...
}: let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    overlays = [
      (final: prev: {
        neovim = prev.neovim.override {
          viAlias = true;
          vimAlias = true;
        };
      })
    ];
  };
in {
  nixpkgs.overlays = [
    (self: super: {
      neovim = pkgs-unstable.neovim;
      # Nix formatter
      alejandra = pkgs-unstable.alejandra;
      home-manager = pkgs-unstable.home-manager;
    })
  ];
}

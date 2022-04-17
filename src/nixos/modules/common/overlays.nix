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
    (final: prev: {
      neovim = pkgs-unstable.neovim;
      # Nix formatter
      alejandra = pkgs-unstable.alejandra;
      home-manager = pkgs-unstable.home-manager;
      flameshot = pkgs-unstable.flameshot;
      drawio = pkgs-unstable.drawio;
      zotero = pkgs-unstable.zotero;
    })
  ];
}

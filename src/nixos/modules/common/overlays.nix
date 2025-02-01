#
# This file centrally handles al the overlays
#
{
  pkgs,
  inputs,
  lib,
  config,
  ...
} @ args: let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  nixpkgs.overlays = [
    (final: prev: {
      # My custom zotero
      zotero = import ./zotero (args // {zotero = prev.zotero;});

      neovim = pkgs-unstable.neovim;
      # Nix formatter
      alejandra = pkgs-unstable.alejandra;
      home-manager = pkgs-unstable.home-manager;
      flameshot = pkgs-unstable.flameshot;
      drawio = pkgs-unstable.drawio;
    })
  ];
}

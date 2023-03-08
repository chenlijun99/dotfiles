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
      # Older version from pkgs doesn't support my vaults
      cryptomator = pkgs-unstable.cryptomator;
    })
  ];
}

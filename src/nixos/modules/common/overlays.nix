#
# This file centrally handles al the overlays
#
{
  pkgs,
  inputs,
  ...
} @ args: let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
  };
in {
  nixpkgs.overlays = [
    (final: prev: {
      # My custom Anki
      anki-bin = pkgs.callPackage ./anki {};
      # My custom okular
      okular = import ./okular args;
      # My custom zotero
      zotero = import ./zotero (args // {zotero = prev.zotero;});

      # See https://github.com/NixOS/nixpkgs/issues/160923#issuecomment-1474989176
      # why this is necessary.
      xdg-desktop-portal-kde = pkgs-unstable.xdg-desktop-portal-kde.overrideAttrs (oldAttrs: rec {
        buildInputs = oldAttrs.buildInputs ++ [pkgs-unstable.plasma-workspace];
      });

      neovim = pkgs-unstable.neovim;
      # Nix formatter
      alejandra = pkgs-unstable.alejandra;
      home-manager = pkgs-unstable.home-manager;
      flameshot = pkgs-unstable.flameshot;
      drawio = pkgs-unstable.drawio;
      # Older version from pkgs doesn't support my vaults
      cryptomator = pkgs-unstable.cryptomator;
    })
  ];
}

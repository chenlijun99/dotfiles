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
  pkgs-pcloud-ok = import inputs.nixpkgs-unstable-pcloud-ok {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
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

      neovim = pkgs-unstable.neovim;
      # Nix formatter
      alejandra = pkgs-unstable.alejandra;
      home-manager = pkgs-unstable.home-manager;
      flameshot = pkgs-unstable.flameshot;
      drawio = pkgs-unstable.drawio;
      # Older version from pkgs doesn't support my vaults
      cryptomator = pkgs-unstable.cryptomator;

      pcloud = pkgs-pcloud-ok.pcloud;
    })
  ];
}

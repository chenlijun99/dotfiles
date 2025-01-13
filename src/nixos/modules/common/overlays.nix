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
  pkgs-pcloud-ok = import inputs.nixpkgs-unstable-pcloud-ok {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
  pkgs-inkscape-1-22 = import inputs.nixpkgs-inkscape-1-22 {
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

      pcloud = pkgs-pcloud-ok.pcloud;
      wechat = pkgs.wechat-uos;
      #
      # New Inkscape 1.3.x are slow when working with PDF.
      # https://inkscape.org/forums/beyond/13-and-131-are-very-very-slow-opening-a-small-pdf-file/
      # I've also experienced this.
      #
      inkscape = pkgs-inkscape-1-22.inkscape;
      fzf-bibtex = import ./fzf-bibtex args;
    })
  ];
  nixpkgs.config.permittedInsecurePackages = [
    # Neede for config.nur.repos.xddxdd.wechat-uos-bin
    "openssl-1.1.1w"
  ];
}

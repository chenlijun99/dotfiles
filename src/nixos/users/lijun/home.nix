{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../common/lijun-base/home.nix
    ../common/kde-config/default.nix
    ./zotero/default.nix
  ];
  nixpkgs.config.allowUnfree = true;
  home = {
    username = "lijun";
    homeDirectory = "/home/lijun";
    packages = with pkgs; [
      # Cloud drive
      pcloud
      nextcloud-client
      cryptomator

      # Anki
      anki-bin

      # Note taking app
      obsidian

      # PDF reader
      okular

      # Email client
      thunderbird

      # A few additional browsers are always useful
      chromium
      microsoft-edge

      # Password manager
      keepassxc

      # Communication
      slack
      teams
      zoom-us
      tdesktop

      # Multimedia
      strawberry
    ];
  };
}

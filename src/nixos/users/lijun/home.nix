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
  ];
  nixpkgs.config.allowUnfree = true;
  home = {
    username = "lijun";
    homeDirectory = "/home/lijun";
    packages = with pkgs; [
      # Cloud drive
      pcloud
      cryptomator
      # Citation manager
      zotero
      # Note taking app
      obsidian
      # Email client
      thunderbird
      # A second browser is always useful
      chromium
      # Password manager
      keepassxc

      # Communication
      slack
      teams
      zoom-us
      tdesktop

      nextcloud-client
    ];
  };
}

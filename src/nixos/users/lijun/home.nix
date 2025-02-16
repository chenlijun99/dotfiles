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
    ./sops.nix
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
      signal-desktop
      teams-for-linux
      zoom-us
      tdesktop
      discord

      # Multimedia
      strawberry
      ffmpeg

      syncthing
      syncthingtray

      # Misc
      scrcpy
      digikam
      # KDE scanner application
      kdePackages.skanlite
      # KDE scanner application for multi-page scanning
      skanpage
      # KDE audio recorder
      kdePackages.krecorder
      # Screen stream&recording
      obs-studio
      # Conversion utility
      imagemagickBig

      # Money-related
      hledger
      hledger-ui
      hledger-web

      gnome-pomodoro
    ];
  };
}

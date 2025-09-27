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
    ./activitiywatch/default.nix
    ./sops.nix
    ./syncthing.nix
  ];
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
      kdePackages.okular

      # Email client
      thunderbird

      # A few additional browsers are always useful
      chromium

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

      # Misc
      scrcpy
      digikam
      # KDE scanner application
      kdePackages.skanlite
      # KDE scanner application for multi-page scanning
      kdePackages.skanpage
      # KDE audio recorder
      kdePackages.krecorder
      # Screen stream&recording
      obs-studio
      # Conversion utility
      imagemagickBig

      gnome-pomodoro
    ];
  };
}

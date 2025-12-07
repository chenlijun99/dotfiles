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
  home = {
    username = "lijun-gui";
    homeDirectory = "/home/lijun-gui";
    packages = with pkgs; [
      # PDF reader
      kdePackages.okular
    ];
  };
}


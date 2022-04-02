{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common/lijun-base/home.nix
  ];
  nixpkgs.config.allowUnfree = true;
  home = {
    username = "lijun";
    homeDirectory = "/home/lijun";
    packages = with pkgs; [
      # Cloud drive
      pcloud
      # Citation manager
      zotero
      # Note taking app
      obsidian
    ];
  };
}

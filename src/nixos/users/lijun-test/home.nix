{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common/lijun-base/home.nix
    ../common/kde-config/default.nix
  ];
  home = {
    username = "lijun-test";
    homeDirectory = "/home/lijun-test";
  };
}


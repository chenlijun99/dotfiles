{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common/lijun-base/home.nix
  ];
  home = {
    username = "lijun-test";
    homeDirectory = "/home/lijun-test";
  };
}


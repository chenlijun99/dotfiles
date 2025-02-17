{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common/lijun-cli-base/home.nix
    ../lijun/sops.nix
  ];
  home = {
    username = "lijun-cli";
    homeDirectory = "/home/lijun-cli";
  };
}

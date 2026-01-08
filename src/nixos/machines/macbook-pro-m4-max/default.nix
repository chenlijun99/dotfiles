#
# Nix-darwin config for running on a MacBook Pro M4 Max
#
{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  users.users."lijun.chen" = {
    home = "/Users/lijun.chen";
    shell = pkgs.zsh;
  };
  home-manager.users."lijun.chen" = {
    imports = [../../users/lijun-cli/home.nix];
    home = {
      username = lib.mkForce "lijun.chen";
      homeDirectory = lib.mkForce "/Users/lijun.chen";
    };
  };
}

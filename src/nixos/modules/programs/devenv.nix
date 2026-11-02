# devenv and its binary cache
{...}: let
  cacheConfig = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  systemModule = {
    config,
    lib,
    ...
  }: {
    options.clj.programs.devenv.enable = lib.mkEnableOption "devenv" // {default = true;};

    config = lib.mkIf config.clj.programs.devenv.enable {
      nix.extraOptions = cacheConfig;
    };
  };
in {
  flake.modules.nixos.clj-devenv = systemModule;
  flake.modules.darwin.clj-devenv = systemModule;

  flake.modules.homeManager.clj-devenv = args @ {
    config,
    lib,
    pkgs,
    ...
  }: let
    homeManagerRunningInNixOS = builtins.hasAttr "osConfig" args;
  in {
    options.clj.programs.devenv.enable = lib.mkEnableOption "devenv" // {default = true;};

    config = lib.mkIf config.clj.programs.devenv.enable {
      home.packages = [pkgs.devenv];
      nix.extraOptions = lib.mkIf (!homeManagerRunningInNixOS) cacheConfig;
    };
  };
}

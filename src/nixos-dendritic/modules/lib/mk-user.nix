# Thin wrapper for creating users with Home Manager integration
# Returns flake-parts modules for NixOS, Darwin, and standalone Home Manager
{
  self,
  lib,
  ...
}: {
  config.flake.lib.mkUser = username: {
    system ? {},
    nixos ? {},
    darwin ? {},
    homeManager ? {},
  }: let
    # Home Manager module with platform-aware defaults
    hmModule = {pkgs, ...}: {
      imports = [
        homeManager
      ];
      home = {
        username = lib.mkDefault username;
        # Auto-detect home directory based on platform
        homeDirectory = lib.mkDefault (
          if pkgs.stdenv.isDarwin
          then "/Users/${username}"
          else "/home/${username}"
        );
      };
    };
  in {
    # NixOS module: system user + Home Manager integration
    nixosModule = {pkgs, ...}: {
      imports = [
        self.modules.nixos.clj-home-manager
      ];

      users.users.${username} = lib.mkMerge [
        {
          isNormalUser = lib.mkDefault true;
        }
        system
        nixos
      ];

      home-manager.users.${username} = hmModule;
    };

    # Darwin module: system user + Home Manager integration
    darwinModule = {pkgs, ...}: {
      imports = [
        self.modules.darwin.clj-home-manager
      ];

      users.users.${username} = lib.mkMerge [
        system
        darwin
        {
          home = lib.mkDefault "/Users/${username}";
        }
      ];

      home-manager.users.${username} = hmModule;
    };

    # Standalone Home Manager module
    homeConfiguration = hmModule;
  };
}

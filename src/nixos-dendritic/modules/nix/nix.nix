# Nix and nixpkgs configuration
{
  self,
  inputs,
  ...
}: let
  commonSystemConfig = {pkgs, ...}: {
    nix = {
      # From the docs:
      # > This option specifies the Nix package instance to use throughout the system.
      #
      # So with this we control which version of nix (the package manager) we want to use
      #
      # pkgs.nixVersions.stable is an alias of a version of nix that supports flakes
      #
      # NOTE that setting this on nix-darwin means that the nix executable will
      # be managed by nix-darwin and replaces the default nix that comes with
      # the nix (lix) executable that installer (e.g., Lix or Determine Nix
      # installer).
      package = pkgs.nixVersions.stable;
      # To suppress the warning:
      # warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
      # See https://github.com/NixOS/nix/issues/2982#issuecomment-2477618346
      channel.enable = false;
      extraOptions = ''
        experimental-features = nix-command flakes
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';
      # Pinning Nixpkgs. See https://www.tweag.io/blog/2020-07-31-nixos-flakes/
      registry.nixpkgs.flake = inputs.nixpkgs-unstable;
    };
  };
in {
  flake.modules.nixos.clj-nix = {
    lib,
    pkgs,
    ...
  }: {
    imports = [commonSystemConfig];
    # nix-ld is pretty neat for running unpatched binaries
    # See https://github.com/nix-community/nix-ld
    programs.nix-ld.enable = true;
    # Let 'nixos-version --json' know about the Git revision of this flake.
    system.configurationRevision = lib.mkIf (self ? rev) self.rev;
  };

  flake.modules.darwin.clj-nix = {
    lib,
    pkgs,
    ...
  }: {
    imports = [commonSystemConfig];
  };
}

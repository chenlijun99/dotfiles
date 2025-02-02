#
# Common nixos configuration shared among machines
#
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./base.nix
    ./overlays.nix
  ];
  nix = {
    # From the docs:
    # This option specifies the Nix package instance to use throughout the system.
    #
    # So with this we control which version of nix (the package manager) we want to use
    #
    # pkgs.nixVersions.stable is an alias of a version of nix that supports flakes
    package = pkgs.nixVersions.stable;
    # To suppress the warning:
    # warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
    # See https://github.com/NixOS/nix/issues/2982#issuecomment-2477618346
    channel.enable = false;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # Pinning Nixpkgs. See https://www.tweag.io/blog/2020-07-31-nixos-flakes/
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = with inputs; nixpkgs.lib.mkIf (self ? rev) self.rev;
}

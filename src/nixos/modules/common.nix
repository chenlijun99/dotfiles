#
# Common nixos configuration shared among machines
#
{
  pkgs,
  inputs,
  ...
}: {
  nix = {
    # From the docs:
    # This option specifies the Nix package instance to use throughout the system.
    #
    # So with this we control which version of nix (the package manager) we want to use
    #
    # pkgs.nixFlakes is an alias of a version of nix that supports flakes
    package = pkgs.nixFlakes;
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

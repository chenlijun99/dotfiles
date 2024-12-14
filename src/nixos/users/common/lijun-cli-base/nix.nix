{
  config,
  pkgs,
  inputs,
  lib,
  ...
} @ args: {
  nix = {
    # lib.mkDefault
    # to workaround error
    # "The option `home-manager.users.lijun.nix.package' is defined multiple times while it's expected to be unique."
    #
    # See also this issue https://github.com/nix-community/home-manager/issues/5870
    package = lib.mkDefault pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

{
  config,
  pkgs,
  inputs,
  ...
} @ args: {
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

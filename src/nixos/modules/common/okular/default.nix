{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: (pkgs.kdePackages.okular.overrideAttrs (oldAttrs: rec {
  patches = (lib.optionals (oldAttrs ? patches) oldAttrs.patches) ++ [./okular.patch];
}))

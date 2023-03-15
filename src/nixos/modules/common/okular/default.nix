{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: (pkgs.libsForQt5.okular.overrideAttrs (oldAttrs: rec {
  patches = (lib.optionals (oldAttrs ? patches) oldAttrs.patches) ++ [./okular.patch];
}))

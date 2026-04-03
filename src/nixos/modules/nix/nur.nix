# NUR (Nix User Repository) integration
{inputs, ...}: {
  flake.modules.nixos.clj-nur = {
    imports = [
      inputs.nur.modules.nixos.default
    ];
  };

  # NUR can also be used on Darwin via overlays
  flake.modules.darwin.clj-nur = {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
  };
}

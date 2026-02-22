# SOPS-nix secrets management
{inputs, ...}: {
  flake.modules.nixos.clj-sops = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
  };

  # Darwin doesn't have a system-level sops module, but home-manager does
  # which is already included via home-manager.sharedModules

  flake.modules.homeManager.clj-sops = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}

{
  description = "NixOS configuration of Lijun Chen";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Use specialArgs to forward parameters to external configuration modules
        specialArgs = attrs;
        modules =
          [
            ./configuration.nix
            ./modules/audio.nix
            ./modules/desktop.nix
            ./modules/users.nix
            ./modules/boot.nix
          ];
      };
    };
  };
}

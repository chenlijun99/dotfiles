# Dendritic NixOS/Darwin/Home-Manager Configuration
# This file is minimal - all logic lives in modules/
{
  description = "NixOS configuration of Lijun Chen (Dendritic)";

  inputs = {
    # Nixpkgs
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Flake-parts for dendritic structure
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Auto-import all modules
    import-tree.url = "github:vic/import-tree";

    # Darwin support
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Impermanence - manage persistent state on ephemeral systems
    impermanence.url = "github:nix-community/impermanence";

    # Hardware optimizations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # NUR for community packages (e.g., WeChat)
    nur.url = "github:nix-community/NUR";

    # Image generation
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree [./modules ./hosts]);
}

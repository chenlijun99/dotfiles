{
  description = "Example: Incus development VM using dotfiles presets";

  inputs = {
    # Use local dotfiles flake (in production, use git URL)
    dotfiles.url = "path:../..";

    # We can use the same flake inputs as the dotfiles flake
    nixpkgs.follows = "dotfiles/nixpkgs-unstable";
    # Or override with our own if needed
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    dotfiles,
    nixpkgs,
    ...
  }: let
    # Create dev user with mkUser helper
    user = dotfiles.lib.mkUser "dev" {
      system = {
        description = "Development User";
        extraGroups = ["wheel" "docker"];
        initialPassword = "dev";
      };
      homeManager = {
        imports = [dotfiles.modules.homeManager.clj-preset-minimal];
        home.stateVersion = "26.05";
      };
    };
  in {
    # Minimal VM configuration using dendritic presets
    nixosConfigurations.incus-dev-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import a preset
        dotfiles.modules.nixos.clj-preset-minimal

        # Import the nixos module for the user (includes HM integration)
        user.nixosModule

        # Host-specific configuration
        {
          # System settings
          networking.hostName = "incus-dev";
          system.stateVersion = "26.05";

          # Boot configuration for VM
          boot.loader.grub.enable = true;
          boot.loader.grub.device = "/dev/sda";

          # Networking
          networking.useDHCP = true;
        }
      ];
    };
  };
}

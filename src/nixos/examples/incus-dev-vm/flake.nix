{
  description = "Example: Incus development VM using dotfiles presets";

  inputs = {
    # Use local dotfiles flake (in production, use git URL)
    dotfiles.url = "path:../..";

    # We can use the same flake inputs as the dotfiles flake
    nixpkgs.follows = "dotfiles/nixpkgs";
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
        imports = [dotfiles.modules.homeManager.clj-preset-development];
        home.stateVersion = "26.05";
      };
    };
  in {
    # Development VM configuration using dendritic presets
    nixosConfigurations.incus-dev-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import a preset
        dotfiles.modules.nixos.clj-preset-development

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

          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };

          # Networking
          networking.useDHCP = true;
        }
      ];
    };
  };
}

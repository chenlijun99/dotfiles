# Home Manager integration for NixOS and Darwin
{inputs, ...}: let
  home-manager-config = {
    home-manager = {
      # By default packages will be installed to $HOME/.nix-profile.
      # Setting this to true makes them installed to /etc/profiles.
      # Basically, setting this to true means that the `home.packages` option
      # of home-manager becomes like an alias to users.users.<name>.packages
      # of NixOS/nix-darwin.
      useUserPackages = true;
      # Use the same nixpkgs instance that is used by the system
      # E.g., make overlays work also within home-manager.
      useGlobalPkgs = true;
      backupFileExtension = "bak";
    };
  };
in {
  flake.modules.nixos.clj-home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  flake.modules.darwin.clj-home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}

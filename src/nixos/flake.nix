{
  description = "NixOS configuration of Lijun Chen";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    # Function to create defult (common) system config options
    defFlakeSystem = systemArch: baseCfg:
      nixpkgs.lib.nixosSystem {
        system = "${systemArch}";
        modules = [
          {
            # Introduce additional module parameters
            _module.args = {
              inherit inputs;
            };
          }
          # Include the home-manager NixOS module
          home-manager.nixosModules.home-manager
          {
            # Pass flake inputs to home manager modules
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
          {
            imports = [
              ./modules/common
            ];
          }
          # Apply baseCfg
          baseCfg
        ];
      };
    # Function to create a Flake-based home configuration
    defFlakeHome = system: username:
    # Check https://github.com/nix-community/home-manager/blob/master/flake.nix
    # for arguments of home-manager.lib.homeManagerConfiguration
      home-manager.lib.homeManagerConfiguration {
        inherit system username;
        extraSpecialArgs = {inherit inputs;};
        homeDirectory = "/home/${username}";
        configuration = import ./users/${username}/home.nix;
        # Update the state version as needed.
        # See the changelog here:
        # https://nix-community.github.io/home-manager/release-notes.html#sec-release-21.05
        stateVersion = "21.11";
      };
  in {
    nixosConfigurations = {
      "virtualbox-guest" = defFlakeSystem "x86_64-linux" {
        imports = [./machines/virtualbox-guest];
      };
      "thinkpad-l390-yoga" = defFlakeSystem "x86_64-linux" {
        imports = [./machines/thinkpad-l390-yoga];
      };
    };
    homeConfigurations = {
      "lijun" = defFlakeHome "x86_64-linux" "lijun";
      "lijun-test" = defFlakeHome "x86_64-linux" "lijun-test";
    };
  };
}

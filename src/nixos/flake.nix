{
  description = "NixOS configuration of Lijun Chen";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nixos-generators,
    ...
  } @ inputs: let
    # If using nixpkgs-unstable to build the system, then nixpkgs is also nixpkgs-unstable.
    actual_inputs = unstable:
      if unstable
      then (inputs // {nixpkgs = nixpkgs-unstable;})
      else inputs;

    /*
    Get the common configuration for a NixOS system.

    Params:
      unstable: whether the system should use nixpkgs-unstable
    */
    getNixosSystemModules = unstable: [
      {
        # Introduce additional module parameters
        _module.args = {
          inputs = actual_inputs unstable;
        };
      }
      # Include the home-manager NixOS module
      home-manager.nixosModules.home-manager
      {
        # See https://nix-community.github.io/home-manager/index.html
        # why the following two options are useful
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        # Pass flake inputs to home manager modules
        home-manager.extraSpecialArgs = {
          inputs = actual_inputs unstable;
        };
        # On activation move existing files by appending the given file extension rather than exiting with an error.
        # See more on https://rycee.gitlab.io/home-manager/nixos-options.html
        home-manager.backupFileExtension = "bak";
      }
      {
        imports = [
          ./modules/common
        ];
      }
    ];
    /*
    Function to create a Flake-based standalone home-manager configuration

    Params:
      system (string): the architecture
      username (string): username, must be one in ./users/, except "common"
      unstable: whether the system should use nixpkgs-unstable
    */
    defFlakeHome = system: username: unstable:
    # Check https://github.com/nix-community/home-manager/blob/master/flake.nix
    # for arguments of home-manager.lib.homeManagerConfiguration
      home-manager.lib.homeManagerConfiguration {
        pkgs =
          import (
            if unstable
            then nixpkgs-unstable
            else nixpkgs
          ) {
            inherit system;
            config.allowUnfree = true;
          };
        extraSpecialArgs = {
          inputs = actual_inputs unstable;
        };
        modules = [
          ./users/${username}/home.nix
        ];
      };
  in {
    nixosConfigurations = {
      "thinkpad-l390-yoga" = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          getNixosSystemModules true
          ++ [
            {
              imports = [./machines/thinkpad-l390-yoga];
            }
          ];
      };
    };
    packages = {
      "x86_64-linux" = {
        # Package used by nixos-generators to generate my virtualbox image
        "virtualbox-guest" = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules =
            getNixosSystemModules true
            ++ [
              {
                imports = [./machines/virtualbox-guest];
              }
            ];
          format = "virtualbox";
        };
      };
    };
    homeConfigurations = {
      "lijun" = defFlakeHome "x86_64-linux" "lijun" true;
      "lijun-test" = defFlakeHome "x86_64-linux" "lijun-test" true;
    };
  };
}

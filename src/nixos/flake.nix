{
  description = "NixOS configuration of Lijun Chen";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manage = {
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
    commonModules = [
      {
        # Introduce additional module parameters
        _module.args = {
          inherit inputs;
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
        home-manager.extraSpecialArgs = {inherit inputs;};
      }
      {
        imports = [
          ./modules/common
        ];
      }
    ];
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
      "thinkpad-l390-yoga" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          commonModules
          ++ [
            {
              imports = [./machines/thinkpad-l390-yoga];
            }
          ];
      };
      "virtualbox-guest" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          commonModules
          ++ [
            {
              imports = [./machines/virtualbox-guest];
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
            commonModules
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
      "lijun" = defFlakeHome "x86_64-linux" "lijun";
      "lijun-test" = defFlakeHome "x86_64-linux" "lijun-test";
    };
  };
}

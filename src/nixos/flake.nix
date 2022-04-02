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
              inputs = inputs;
            };
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
          baseCfg
        ];
      };
  in {
    nixosConfigurations = {
      nixos = defFlakeSystem "x86_64-linux" {
        imports = [./machines/virtualbox-guest];
      };
      "thinkpad-l390-yoga" = defFlakeSystem "x86_64-linux" {
        imports = [./machines/thinkpad-l390-yoga];
      };
    };
  };
}

{
  description = "NixOS configuration of Lijun Chen";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
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
          baseCfg
        ];
      };
  in {
    nixosConfigurations = {
      nixos = defFlakeSystem "x86_64-linux" {
        imports = [./machines/virtualbox-guest.nix];
      };
    };
  };
}

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
          # This file is not tracked in Git. Rather, for each NixOS
          # installation, hardware-configuration.nix should be generated using
          # `nixos-generate-config` and linked into this directory (but
          # not tracked into Git)
          ./hardware-configuration.nix
          baseCfg
        ];
      };
  in {
    nixosConfigurations = {
      nixos = defFlakeSystem "x86_64-linux" {
        imports = [./machines/virtualbox-guest.nix];
      };
      "thinkpad-l390-yoga" = defFlakeSystem "x86_64-linux" {
        imports = [./machines/thinkpad-l390-yoga.nix];
      };
    };
  };
}

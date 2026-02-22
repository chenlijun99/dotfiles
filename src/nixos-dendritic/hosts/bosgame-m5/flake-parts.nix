# Bosgame M5 - Flake outputs
{
  inputs,
  self,
  ...
}: let
  hostName = "clj-host-bosgame-m5";
in {
  flake.nixosConfigurations.${hostName} =
    inputs.nixpkgs-unstable.lib.nixosSystem
    {
      system = "x86_64-linux";
      modules = let
        userLijun = self.lib.mkUser "lijun" {
          #system = {
          #password = "password";
          #};
          nixos = {
            isNormalUser = true;
            description = "Lijun Chen";
            extraGroups = ["wheel" "networkmanager" "docker" "dialout" "libvirtd" "wireshark"];
            # Initial password.
            # Change it immediately on the first login!
            hashedPassword = "$6$SUUT8ZWKpI$3/0xAo2JFFOmtBPxSwGGzKdMgD5slbPaZgHWd9l53SELl8ohaMAVDeIiY6E15LXG0Lmqc1wDKSFjM7f/cMArQ.";
          };
          homeManager = {
            imports = [
              self.modules.homeManager.clj-preset-full
              {
                clj.dotfiles.editable = true;
              }
            ];
            home.stateVersion = "25.11";
          };
        };
      in [
        ({pkgs, ...}: {
          imports = with self.modules.nixos; [
            clj-host-bosgame-m5
            clj-host-bosgame-m5-virtualization
            clj-preset-full
            userLijun.nixosModule
          ];
          nixpkgs.config.allowUnfree = true;

          boot.kernelPackages = pkgs.linuxPackages_6_19;
          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };

          networking.hostName = hostName;
          networking.networkmanager.enable = true;
          networking.networkmanager.plugins = [
            pkgs.networkmanager-openvpn
          ];

          hardware.bluetooth.enable = true;

          system.stateVersion = "25.11";
        })
      ];
    };
}

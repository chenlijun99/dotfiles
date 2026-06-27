# NOTE: this module does not provide the hardware config necessary to make
# impermanence work.
# It should be completed with hardware configuration (e.g. tmpfs for rootfs,
# zfs rollback, etc.), that is host-specific.
{
  inputs,
  lib,
  ...
}: let
  mkOptions = {
    # Impermanence is opt-in
    defaultEnable ? false,
  }:
    with lib; {
      clj.impermanence = {
        enable =
          mkEnableOption "impermanence"
          // {
            default = defaultEnable;
          };
        persistDir = mkOption {
          type = types.str;
          default = "/persist";
          description = "Profile name.";
        };
      };
    };
in {
  flake.modules.nixos.clj-impermanence = {
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    options = mkOptions {};

    config = {
      environment.persistence.${config.clj.impermanence.persistDir} = {
        enable = config.clj.impermanence.enable;
        hideMounts = config.clj.impermanence.enable;
        files = [
          "/etc/machine-id"
        ];
        directories = [
          # Logs
          "/var/log"
          # NixOS state (e.g., uid/gid mappings)
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          # Bluetooth pairing state
          "/var/lib/bluetooth"
          # Network connection state (e.g., wifi password)
          "/etc/NetworkManager/system-connections"
        ];
      };
    };
  };

  flake.modules.homeManager.clj-impermanence = {
    config,
    lib,
    osConfig ? null,
    ...
  }: {
    # If impermanence enabled at system level, default to enabling it at home-manager level as well.
    options = mkOptions {defaultEnable = osConfig.clj.impermanence.enable or false;};

    config = {
      home.persistence.${config.clj.impermanence.persistDir} = {
        enable = config.clj.impermanence.enable;
        files = [
          {
            file = ".ssh/known_hosts";
            parentDirectory = {mode = "0700";};
          }
        ];
        directories = [
          "Data"
          "Desktop"
          "Downloads"
          "Repositories"
          ".cache/nix"

          # Development stuff
          ".cache/ccache"
          ".cargo"
        ];
      };
    };
  };
}

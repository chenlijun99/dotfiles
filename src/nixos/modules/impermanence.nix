# NOTE: this module does not provide the hardware config necessary to make
# impermanence work.
# It should be completed with hardware configuration (e.g. tmpfs for rootfs,
# zfs rollback, etc.), that is host-specific.
{
  inputs,
  lib,
  ...
}: let
  options = with lib; {
    clj.impermanence = {
      enable =
        mkEnableOption "impermanence"
        // {
          # Impermanence is opt-in
          default = false;
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

    inherit options;

    config = {
      environment.persistence.${config.clj.impermanence.persistDir} = {
        enable = config.clj.impermanence.enable;
        hideMounts = config.clj.impermanence.enable;
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];
      };
    };
  };

  flake.modules.homeManager.clj-impermanence = {
    config,
    lib,
    ...
  }: {
    inherit options;
  };
}

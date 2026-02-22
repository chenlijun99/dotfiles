# Kanata keyboard remapper
{...}: let
  kanataConfigDir = ../../kanata;
in {
  # NixOS - systemd service
  flake.modules.nixos.clj-kanata = {
    lib,
    config,
    ...
  }: {
    options.clj.kanata.enable = lib.mkEnableOption "Kanata keyboard remapper" // {default = true;};

    config = lib.mkIf config.clj.kanata.enable {
      services.kanata = {
        enable = true;
        keyboards = {
          "normal" = {
            configFile = "${kanataConfigDir}/normal.kbd";
          };
          "rks70" = {
            configFile = "${kanataConfigDir}/rks70.kbd";
          };
        };
      };
    };
  };

  # Darwin - launchd daemon
  flake.modules.darwin.clj-kanata = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.clj.kanata.enable = lib.mkEnableOption "Kanata keyboard remapper" // {default = true;};

    config = lib.mkIf config.clj.kanata.enable {
      environment.systemPackages = with pkgs; [
        kanata
      ];

      launchd.daemons = let
        mkKanataDaemon = configFile: let
          basename = builtins.baseNameOf configFile;
          name = builtins.head (builtins.split "\\." basename);
        in {
          command = "${pkgs.kanata}/bin/kanata -c ${kanataConfigDir}/${configFile}";
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/kanata-${name}.out.log";
            StandardErrorPath = "/tmp/kanata-${name}.err.log";
          };
        };
      in {
        kanata = mkKanataDaemon "apple_iso_international_english.kdb";
        kanata-rks70 = mkKanataDaemon "rks70.kbd";
      };
    };
  };

  # Home-Manager - for non-NixOS Linux systems (requires manual udev setup)
  # Only enables if system-level kanata is not configured
  flake.modules.homeManager.clj-kanata = {
    config,
    lib,
    pkgs,
    osConfig ? {},
    ...
  }: let
    mkKanataService = name: configFile: {
      Unit = {
        Description = "Kanata keyboard remapper - ${name}";
        Documentation = "https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md";
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${pkgs.concatText "kanata-${name}-config" [
          (kanataConfigDir + "/${configFile}")
          (kanataConfigDir + "/common.kbd")
        ]}";
        Restart = "on-failure";
      };
      Install = {WantedBy = ["default.target"];};
    };

    # Define keyboards similar to system config
    keyboards = {
      "normal" = "normal.kbd";
      "rks70" = "rks70.kbd";
    };
  in {
    options.clj.kanata.enable = lib.mkEnableOption "Kanata keyboard remapper" // {default = true;};

    config =
      lib.mkIf
      (let
        # Check if system-level kanata is already configured or explicitly disabled.
        # On NixOS: check osConfig.services.kanata.enable and clj.kanata.enable.
        # On Darwin: check osConfig.launchd.daemons.kanata.
        # If clj.kanata.enable = false at OS level (e.g. in a VM), skip entirely.
        osKanataDisabled = (osConfig.clj.kanata.enable or true) == false;
        systemKanataEnabled =
          (osConfig.services.kanata.enable or false)
          || (osConfig.launchd.daemons ? kanata);
      in (config.clj.kanata.enable && !osKanataDisabled && !systemKanataEnabled)) {
        home.packages = [pkgs.kanata];

        systemd.user.services = (
          lib.mapAttrs' (name: configFile:
            lib.nameValuePair "kanata-${name}" (mkKanataService name configFile))
          keyboards
        );
      };
  };
}

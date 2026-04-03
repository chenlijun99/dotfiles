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

      # NOTE: known race condition on macOS boot
      #
      # When the RKS70 is not connected at boot, kanata-rks70's
      # macos-dev-names-include finds no matching device and falls back to
      # intercepting ALL keyboards. This races with kanata-apple, and
      # occasionally kanata-rks70 wins, applying the wrong config to the
      # Apple internal keyboard.
      #
      # The underlying kanata bug is tracked in:
      #   https://github.com/jtroo/kanata/pull/1986
      #   (fix: exit instead of falling back to all devices when filter matches nothing)
      #
      # A proper macOS solution (equivalent to linux-continue-if-no-devs-found)
      # is tracked in:
      #   https://github.com/malpern/kanata/pull/11
      #   (adds macos-continue-if-no-devs-found, watches for device connection via IOKit)
      #
      # Manual workaround when the Apple keyboard gets the wrong config on boot:
      #   sudo launchctl bootout system/org.nixos.kanata-rks70
      #   sudo pkill kanata   # kills kanata-apple; launchd will restart it cleanly
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
        # RunAtLoad = false: don't start on boot. When the RKS70 is absent,
        # kanata falls back to intercepting all keyboards and races with
        # kanata-apple (see the note above). Start manually after plugging in:
        #   sudo launchctl kickstart system/org.nixos.kanata-rks70
        kanata-rks70 = lib.mkMerge [
          (mkKanataDaemon "rks70.kbd")
          {serviceConfig = {RunAtLoad = lib.mkForce false;};}
        ];
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

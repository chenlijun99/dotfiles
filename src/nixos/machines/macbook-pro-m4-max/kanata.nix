#
# Kanata config for Nix-darwin
#
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Need kanata binary to be located at a fixed path (even if just system link).
    # So as to add the binary to the ones allowed for input monitoring and
    # accessibility.
    kanata
  ];

  launchd = {
    daemons = let
      katataConfigDir = ../../../kanata;

      mkKanataDaemon = configFile: let
        basename = builtins.baseNameOf configFile;
        name = builtins.head (builtins.split "\\." basename);
      in {
        command = "${pkgs.kanata}/bin/kanata -c ${katataConfigDir}/${configFile}";
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
}

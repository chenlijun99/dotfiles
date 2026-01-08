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
    daemons = {
      kanata = let
        katataConfigDir = ../../../kanata;
      in {
        command = "${pkgs.kanata}/bin/kanata -c ${katataConfigDir}/apple_iso_international_english.kdb";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/kanata.out.log";
          StandardErrorPath = "/tmp/kanata.err.log";
        };
      };
    };
  };
}

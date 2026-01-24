#
# System-wide configuration related to Kanata
#
{...}: {
  services.kanata = let
    katataConfigDir = ../../kanata;
  in {
    enable = true;
    keyboards = {
      "normal" = {
        configFile = "${katataConfigDir}/normal.kbd";
      };
      "rks70" = {
        configFile = "${katataConfigDir}/rks70.kbd";
      };
    };
  };
}

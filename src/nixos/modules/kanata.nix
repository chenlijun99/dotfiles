#
# System-wide configuration related to Kanata
#
{pkgs, ...}: {
  services.kanata = {
    enable = true;
    # NOTE: need to concatText because configFile copies only the file itself, not the files it includes.
    # Kanata thus fails to start since the configuration file is incomplete.
    keyboards = {
      "normal" = {
        configFile = pkgs.concatText "kanata-normal-config" [../../kanata/normal.kbd ../../kanata/common.kbd];
      };
      "rks70" = {
        configFile = pkgs.concatText "kanata-normal-config" [../../kanata/rks70.kbd ../../kanata/common.kbd];
      };
    };
  };
}

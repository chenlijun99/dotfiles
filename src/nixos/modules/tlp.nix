#
# TLP configuration
#
{...}: {
  # This service conflicts with TLP.
  # I prefer TLP because it also allows me to configure the charge thresholds..
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}

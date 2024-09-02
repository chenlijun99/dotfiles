#
# Embedded programming
#
{pkgs, ...}: {
  # I needed this to debug ESP32 with openocd
  services.udev.packages = [pkgs.openocd];
}

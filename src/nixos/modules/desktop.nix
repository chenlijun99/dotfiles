#
# System-wide configuration related to desktop environment
#
{pkgs, ...}: {
  services.displayManager = {
    sddm.enable = true;
  };
  services.xserver.enable = true;
  services.desktopManager = {
    plasma6.enable = true;
  };
  # for touchpad support on many laptops
  services.libinput.enable = true;
  # Fixes https://github.com/NixOS/nixpkgs/issues/145354
  # I need to this open Zotero links
  xdg.portal = {
    xdgOpenUsePortal = true;
    enable = true;
  };
}

#
# System-wide configuration related to desktop environment
#
{pkgs, ...}: {
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5 = {
      enable = true;
    };
    libinput.enable = true; # for touchpad support on many laptops
  };

  # Fixes https://github.com/NixOS/nixpkgs/issues/145354
  # I need to this open Zotero links
  xdg.portal = {
    xdgOpenUsePortal = true;
    enable = true;
  };
}

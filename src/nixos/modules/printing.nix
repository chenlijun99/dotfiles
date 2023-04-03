#
# System-wide configuration related to printing
#
# See:
#
# * https://nixos.wiki/wiki/Printing
#
{pkgs, ...}: {
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;
}

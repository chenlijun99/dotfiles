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
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;
}

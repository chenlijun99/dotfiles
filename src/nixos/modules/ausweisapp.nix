#
# This program needs to be added system-wise because it requires
# opening some port on the firewall
#
{...}: {
  programs.ausweisapp.enable = true;
  programs.ausweisapp.openFirewall = true;
}

#
# System-wide configuration related to Virtualbox
#
# See https://nixos.wiki/wiki/VirtualBox
#
{...}: {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["lijun"];
}

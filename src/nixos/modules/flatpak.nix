#
# Flatpak
#
{...}: {
  services.flatpak.enable = true;

  # See https://nixos.wiki/wiki/Fonts for workarounds to make system fonts
  # accessible by Flatpak.
  fonts.fontDir.enable = true;
}

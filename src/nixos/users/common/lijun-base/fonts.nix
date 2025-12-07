{pkgs, ...}: {
  # Allow fontconfig to discover fonts and configurations installed through home.packages and
  fonts.fontconfig.enable = true;
  home.packages = [
    # Used for terminal stuff
    pkgs.nerd-fonts.hack
  ];
}

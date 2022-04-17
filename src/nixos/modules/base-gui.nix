#
# Base packages that all users who operate in a GUI environment can use
#
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    gparted
  ];

  # Input method for chinese
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [libpinyin];

  # Install fonts
  # See https://nixos.wiki/wiki/Fonts
  fonts.fonts = with pkgs; [
    noto-fonts-cjk
    # I use this font in terminal emulator
    # My Alacritty config uses NerdFont patched Hack
    (nerdfonts.override {fonts = ["Hack"];})
  ];
}

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
    gnome.gnome-disk-utility
    # Main browser that all the users can use
    # This is a prebuilt binary from Mozilla.
    # NixOS provides also "firefox", which is built using Nix.
    #
    # NOTE: We use this because it doesn't cause problems with Latte-dock.
    firefox-bin
  ];

  # Input method for chinese
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [rime];

  # Install fonts
  # See https://nixos.wiki/wiki/Fonts
  fonts.fonts = with pkgs; [
    noto-fonts-cjk
    noto-fonts-emoji
    # I use this font in terminal emulator
    # My Alacritty config uses NerdFont patched Hack
    (nerdfonts.override {fonts = ["Hack"];})
  ];
}

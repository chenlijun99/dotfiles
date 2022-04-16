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

  # Install fonts
  # I use this font in terminal emulator
  fonts.fonts = with pkgs; [
    # My Alacritty config uses NerdFont patched Hack
    (nerdfonts.override {fonts = ["Hack"];})
  ];
}

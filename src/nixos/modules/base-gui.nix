#
# Base packages that all users who operate in a GUI environment can use
#
{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gparted
    gnome-disk-utility
    gnome-calculator
    # Main browser that all the users can use
    # This is a prebuilt binary from Mozilla.
    # NixOS provides also "firefox", which is built using Nix.
    #
    # NOTE: We use this because it doesn't cause problems with Latte-dock.
    firefox-bin
  ];

  # Input method for chinese
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        kdePackages.fcitx5-qt
        kdePackages.fcitx5-chinese-addons
        rime-data
        fcitx5-rime
        rime-ice
      ];
    };
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        emoji = ["Noto Color Emoji"];

        # Use Hack Nerd Font as main monospace font.
        # I've been using it in the terminal (Alacritty) for so many years.
        # If characters are not supported by Hack Nerd Font
        # fallback to font family emoji and then to JuliaMono.
        #
        # JuliaMono is a monospace font that supports many unicode math
        # characters. Useful for Isabelle/HOL.
        #
        # `emoji` comes first because otherwise JuliaMono also contains
        # support for some emojis but I want to use JuliaMono only for
        # math symbols.
        #
        # To debug font priority you can use `fc-match`.
        # Also, of course, ArchWiki is always a nice source.
        # [Font configuration](https://wiki.archlinux.org/title/Font_configuration)
        monospace = ["Hack Nerd Font" "emoji" "JuliaMono" "DejaVu Sans Mono"];
      };
    };
    # Install fonts
    # See https://nixos.wiki/wiki/Fonts
    packages = with pkgs; [
      noto-fonts-cjk-sans
      # Not sure why, BaiduNetDisk doesn't pick up `noto-fonts-cjk-sans`.
      # This font works OTOH.
      wqy_zenhei
      noto-fonts-color-emoji
      # I need a monospace font that supports as many math unicode characters as possible
      #
      # A few characters that I often encounter in Isabelle/HOL
      # "⟹", "⇒", "⋀", "→", "⊢", "∧", "∨", "∈", "⊆", "∀"
      # Use this command to look for fonts on my sytem that support the above characters.
      # `fc-list :charset=27F9,21D2,22C0,2192,22A2,2227,2228,2208,2286,2200`
      #
      # For now, this font is the best I've come across.
      julia-mono
      nerd-fonts.hack
    ];
  };
}

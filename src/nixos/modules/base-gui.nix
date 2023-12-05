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
    gnome.gnome-calculator
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

  fonts = {
    fontconfig = {
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!--
              If characters are not supported by Hack Nerd Font 
              (my main monospace font that I use in Alacritty)
              fallback to font family emoji and then to JuliaMono.

              JuliaMono is a monospace font that supports many unicode math 
              characters. Useful for Isabelle/HOL.

              `emoji` comes first because otherwise JuliaMono also contains
              support for some emojis but I want to use JuliaMono only for
              math symbols.
          -->
          <alias binding="weak">
            <family>Hack Nerd Font</family>
            <prefer>
              <family>emoji</family>
              <family>JuliaMono</family>
            </prefer>
          </alias>

          <!--
              Take from 
              https://github.com/NixOS/nixpkgs/issues/86601#issuecomment-757959059

              To make the emoji font I like (i.e. Noto Color Emoji) to come first 
              when falling back.
              Chromium works fine without this. But Alacritty needs this.
          -->
          <alias binding="weak">
            <family>monospace</family>
            <prefer>
              <family>emoji</family>
            </prefer>
          </alias>
          <alias binding="weak">
            <family>sans-serif</family>
            <prefer>
              <family>emoji</family>
            </prefer>
          </alias>
          <alias binding="weak">
            <family>serif</family>
            <prefer>
              <family>emoji</family>
            </prefer>
          </alias>
        </fontconfig>
      '';
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["DejaVu Sans Mono" "JuliaMono"];
      };
    };
    # Install fonts
    # See https://nixos.wiki/wiki/Fonts
    packages = with pkgs; [
      noto-fonts-cjk
      noto-fonts-emoji
      # I need a monospace font that supports as many math unicode characters as possible
      #
      # A few characters that I often encounter in Isabelle/HOL
      # "⟹", "⇒", "⋀", "→", "⊢", "∧", "∨", "∈", "⊆", "∀"
      # Use this command to look for fonts on my sytem that support the above characters.
      # `fc-list :charset=27F9,21D2,22C0,2192,22A2,2227,2228,2208,2286,2200`
      #
      # For now, this font is the best I've come across.
      julia-mono
      # I use this font in terminal emulator
      # My Alacritty config uses NerdFont patched Hack
      (nerdfonts.override {fonts = ["Hack"];})
    ];
  };
}

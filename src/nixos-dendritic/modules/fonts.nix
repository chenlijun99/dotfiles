{...}: {
  flake.modules.homeManager.clj-fonts = {pkgs, ...}: {
    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = ["Noto Color Emoji"];
          monospace = ["Hack Nerd Font" "emoji" "JuliaMono" "DejaVu Sans Mono"];
        };
      };
    };
    home.packages = with pkgs; [
      noto-fonts-cjk-sans
      wqy_zenhei
      noto-fonts-color-emoji
      julia-mono
      # Used for terminal stuff
      nerd-fonts.hack
    ];
  };
}

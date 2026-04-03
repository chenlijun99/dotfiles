{
  flake.modules.homeManager.clj-alacritty = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.clj.programs.alacritty.enable = lib.mkEnableOption "alacritty terminal emulator" // {default = true;};

    config = lib.mkIf config.clj.programs.alacritty.enable {
      home.packages = with pkgs; [
        alacritty
        # Used for bell sound in Alacritty
        # E.g. `echo '\a'`
        xkbutils
      ];
      xdg.configFile = {
        "alacritty" = {
          source = config.lib.clj.linkDotfile "src/config/alacritty/";
        };
      };
    };
  };
}

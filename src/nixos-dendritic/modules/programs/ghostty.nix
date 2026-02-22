{self, ...}: {
  # Darwin uses Homebrew for the latest tip release
  flake.modules.darwin.clj-ghostty = {
    config,
    lib,
    ...
  }: {
    options.clj.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator" // {default = true;};

    config = lib.mkIf config.clj.programs.ghostty.enable {
      homebrew.casks = [
        "ghostty@tip"
      ];
    };
  };

  # Home-Manager config (shared config, package only on non-Darwin)
  flake.modules.homeManager.clj-ghostty = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.clj.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator" // {default = true;};

    config = lib.mkIf config.clj.programs.ghostty.enable {
      # Only install the package on non-Darwin (Darwin uses homebrew)
      home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [
        pkgs.ghostty
      ];
      xdg.configFile = {
        "ghostty_config" = {
          source = config.lib.clj.linkDotfile "src/config/ghostty/config";
          target = "ghostty/config";
        };
        "ghostty_config_platform" = {
          source = config.lib.clj.linkDotfile (
            if pkgs.stdenv.isDarwin
            then "src/config/ghostty/config_macos"
            else "src/config/ghostty/config_linux"
          );
          target = "ghostty/config_platform";
        };
      };
    };
  };
}

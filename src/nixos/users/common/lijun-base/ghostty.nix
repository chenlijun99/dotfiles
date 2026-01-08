{
  config,
  pkgs,
  lib,
  ...
}: {
  # On nix-darwin I just ghostty from homebrew
  home = lib.mkIf (!pkgs.stdenv.isDarwin) {
    packages = with pkgs; [
      ghostty
    ];
  };
  xdg.configFile = {
    "ghostty" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/ghostty/";
    };
  };
}

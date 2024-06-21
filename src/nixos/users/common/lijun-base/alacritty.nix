{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  home = {
    packages = with pkgs; [
      alacritty
      # Used for bell sound in Alacritty
      # E.g. `echo '\a'`
      xorg.xkbutils
    ];
  };
  xdg.configFile = {
    "alacritty" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/alacritty/";
    };
  };
}

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
    ];
  };
  xdg.configFile = {
    "alacritty" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/alacritty/";
    };
  };
}

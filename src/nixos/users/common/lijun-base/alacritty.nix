{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = with pkgs; [
      alacritty
    ];
  };
  xdg.configFile = {
    "alacritty" = {
      source = ../../../../config/alacritty;
    };
  };
}

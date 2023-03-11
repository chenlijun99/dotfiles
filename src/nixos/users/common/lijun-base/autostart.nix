{
  config,
  pkgs,
  inputs,
  ...
}: {
  xdg.configFile = {
    "autostart/clj_de_autostart.sh.desktop" = {
      source = ../../../../config/autostart/clj_de_autostart.sh.desktop;
    };
  };
}

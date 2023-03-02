{
  config,
  pkgs,
  inputs,
  ...
}: {
  xdg.configFile = {
    "nvim" = {
      source = ../../../../vim;
      target = "nvim";
    };
  };
  home = {
    file = {
      "vim" = {
        source = ../../../../vim;
        target = ".vim";
      };
      "vimrc" = {
        source = ../../../../vimrc;
        target = ".vimrc";
      };
    };
  };
}

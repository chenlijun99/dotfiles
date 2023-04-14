# This module contains every package that I need for Neovim
# when I work in a graphical environment
{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = with pkgs; [
      # To support neovim clipboard
      xclip
      wl-clipboard
    ];
  };
}

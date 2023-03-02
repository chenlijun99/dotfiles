{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = with pkgs; [
      tmux
      # For tmux-yank
      xsel
    ];
    file = {
      "tmux" = {
        source = ../../../../tmux;
        target = ".tmux";
      };
      "tmux.conf" = {
        source = ../../../../tmux.conf;
        target = ".tmux.conf";
      };
    };
  };
}

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
      tmux
      # For tmux-yank
      xsel
    ];
    file = {
      ".tmux" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/tmux";
      };
      ".tmux.conf" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/tmux.conf";
      };
    };
  };
}

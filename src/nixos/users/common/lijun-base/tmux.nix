{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ./utils.nix args;
in {
  home = {
    packages = with pkgs; [
      tmux
      # For tmux-yank
      xsel
    ];
    file = {
      ".tmux" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/tmux";
      };
      ".tmux.conf" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/tmux.conf";
      };
    };
  };
}

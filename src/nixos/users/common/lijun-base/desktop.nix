{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  home.file = {
    ".local/share/applications/clj_time_to_sleep.desktop" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_time_to_sleep.desktop";
    };
    ".local/share/applications/clj_alacritty-vim.desktop" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_alacritty-vim.desktop";
    };
  };
}

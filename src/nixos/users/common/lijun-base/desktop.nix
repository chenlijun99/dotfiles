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
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_time_to_sleep.desktop";
    };
    ".local/share/applications/clj_alacritty-vim.desktop" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_alacritty-vim.desktop";
    };

    ".local/share/applications/clj_switch_to_dolphin.desktop" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_switch_to_dolphin.desktop";
    };
    ".local/share/applications/clj_switch_to_firefox.desktop" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_switch_to_firefox.desktop";
    };
    ".local/share/applications/clj_switch_to_alacritty.desktop" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_switch_to_alacritty.desktop";
    };
    ".local/share/applications/clj_switch_to_keepassxc.desktop" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/local/share/applications/clj_switch_to_keepassxc.desktop";
    };
  };
}

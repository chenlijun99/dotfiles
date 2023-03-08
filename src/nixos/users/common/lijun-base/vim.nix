{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ./utils.nix args;
in {
  xdg.configFile = {
    "nvim" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vim/";
    };
  };
  home = {
    file = {
      ".vim" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vim/";
      };
      ".vimrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vimrc";
      };
    };
  };
}

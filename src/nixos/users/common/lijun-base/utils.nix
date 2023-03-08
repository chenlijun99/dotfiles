{
  config,
  pkgs,
  inputs,
  ...
}: rec {
  THIS_REPO_PATH = "${config.home.homeDirectory}/Repositories/personal/dotfiles/";
  mkOutOfStoreRelativeThisRepoSymLink = relativePath: config.lib.file.mkOutOfStoreSymlink (THIS_REPO_PATH + relativePath);
}

{
  pkgs,
  lib,
  config,
  ...
} @ args: let
  utils = import ./utils.nix args;
in {
  home = {
    packages = with pkgs; [
      git
    ];

    activation = {
      # This activation clones this repository in $HOME/Repositories/personal/dotfiles
      # if it is not already present.
      # This is done before "writeBoundary", so that we're sure that this
      # repository surely exists before home-manager creates system links to
      # it.
      thisRepository = lib.hm.dag.entryBefore ["writeBoundary"] ''
        if ! [ -d ${utils.THIS_REPO_PATH} ]
        then
          $DRY_RUN_CMD git clone --recursive https://github.com/chenlijun99/dotfiles ${utils.THIS_REPO_PATH}
        fi
      '';
    };
  };
}

# "lijun-base" contains everything that I normally use to work, excluding
# stuff such as note taking, messaging, etc.
{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ./utils.nix args;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./tmux.nix
    ./vim.nix
    ./shell.nix
    ./firefox.nix
    ./alacritty.nix
    ./flameshot.nix
    ./this.nix
    ./autostart.nix
    ./desktop.nix
    # My custom scripts
    ./../../../../local/bin/scripts.nix
  ];
  home = {
    # See https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
    stateVersion = "21.11";
    packages = with pkgs; [
      # Ripgrep. I use it in Vim and also on CLI
      ripgrep
      ripgrep-all
      fzf
      # I never use it, but it may be useful
      vscode
      # Lightweight PDF reader
      zathura
      # For offline documentation
      zeal
      # Disk usage statistics
      libsForQt5.filelight
      # Latex
      texlive.combined.scheme-medium
      plantuml
      graphviz
      doxygen
      drawio
      pandoc
      libreoffice
      xournalpp
      vlc
      # Protect my eyes
      safeeyes
      ##########################################################################
      # Dev tools
      ##########################################################################
      # C/C++ debuggers
      gdb
      lldb
    ];
    file = {
      ".vifm" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vifm";
      };
      ".ctags" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/ctags";
      };
      ".detoxrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/detoxrc";
      };
      ".gdbinit" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/gdbinit";
      };
      ".gitconfig" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/gitconfig";
      };
      ".ls_colors" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/ls_colors";
      };
      ".markdownlintrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/markdownlintrc";
      };
      ".xbindkeysrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/xbindkeysrc";
      };
      # GNU readline config
      # Mostly for Vim keybindings
      ".inputrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/inputrc";
      };
    };
  };
  # Enable management of XDG base directories using home-manager
  xdg.enable = true;
  xdg.configFile = {
    "ibus" = {
      /*
      NOTE: don't let home-manager handle the whole `config/ibus` folder,
      since it would cause the `config/ibus` folder to be read-only.
      The `config/ibus` folder also contains stateful data that the ibus-daemon
      needs to write.
      */
      source = ../../../../config/ibus/rime/default.custom.yaml;
      target = "ibus/rime/default.custom.yaml";
    };
    "safeeyes" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/safeeyes";
    };
    "zathura" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/zathura";
    };
  };
}

# "lijun-base" contains everything that I normally use to work, excluding
# stuff such as note taking, messaging, etc.
{
  config,
  pkgs,
  inputs,
  ...
}: {
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
      "vifm" = {
        source = ../../../../vifm;
        target = ".vifm";
      };
      "ctags" = {
        source = ../../../../ctags;
        target = ".ctags";
      };
      "detoxrc" = {
        source = ../../../../detoxrc;
        target = ".detoxrc";
      };
      "gdbinit" = {
        source = ../../../../gdbinit;
        target = ".gdbinit";
      };
      "gitconfig" = {
        source = ../../../../gitconfig;
        target = ".gitconfig";
      };
      "ls_colors" = {
        source = ../../../../ls_colors;
        target = ".ls_colors";
      };
      "markdownlintrc" = {
        source = ../../../../markdownlintrc;
        target = ".markdownlintrc";
      };
      "xbindkeysrc" = {
        source = ../../../../xbindkeysrc;
        target = ".xbindkeysrc";
      };
      # GNU readline config
      # Mostly for Vim keybindings
      "inputrc" = {
        source = ../../../../inputrc;
        target = ".inputrc";
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
      source = ../../../../config/safeeyes;
      target = "safeeyes";
    };
    "zathura" = {
      source = ../../../../config/zathura;
      target = "zathura";
    };
  };
}

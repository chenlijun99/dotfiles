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
  ];
  home = {
    # See https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
    stateVersion = "21.11";
    packages = with pkgs; [
      # Ripgrep. I use it in Vim and also on CLI
      ripgrep
      ripgrep-all
      # My terminal of choice
      alacritty
      fzf
      # I never use it, but it may be useful
      vscode
      # Lightweight PDF reader
      zathura
      # For offline documentation
      zeal
      # Screenshot tool
      flameshot
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
      ##
      # Dev tools (formatters, linters, etc)
      ##
      gdb
      # C/C++ debugger based on LLVM
      lldb
      clang_12
      yamllint
      nodePackages.markdownlint-cli
      nodePackages.stylelint
      nodePackages.eslint_d
      nodePackages.prettier
      # Lua formatter
      stylua
      # Language server, clang-format, clang-tidy
      clang-tools
      # Assembly formatter
      asmfmt
      cmake-format
      shellcheck
      cppcheck
      lua53Packages.luacheck
      black
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
      "npmrc" = {
        source = ../../../../npmrc;
        target = ".npmrc";
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
    "alacritty" = {
      source = ../../../../config/alacritty;
      target = "alacritty";
    };
    "conky" = {
      source = ../../../../config/conky;
      target = "conky";
    };
    "Dharkael" = {
      source = ../../../../config/Dharkael;
      target = "Dharkael";
    };
    "dunst" = {
      source = ../../../../config/dunst;
      target = "dunst";
    };
    "flameshot" = {
      source = ../../../../config/flameshot;
      target = "flameshot";
    };
    "i3" = {
      source = ../../../../config/i3;
      target = "i3";
    };
    "ibus" = {
      source = ../../../../config/ibus;
      target = "ibus";
    };
    "picom" = {
      source = ../../../../config/picom;
      target = "picom";
    };
    "polybar" = {
      source = ../../../../config/polybar;
      target = "polybar";
    };
    "redshift" = {
      source = ../../../../config/redshift;
      target = "redshift";
    };
    "rofi" = {
      source = ../../../../config/rofi;
      target = "rofi";
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

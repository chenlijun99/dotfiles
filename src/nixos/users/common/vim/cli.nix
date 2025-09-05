# This module contains every CLI tool that I need for Neovim
{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  xdg.configFile = {
    "nvim" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/vim/";
    };
  };
  home = {
    packages = with pkgs; [
      (neovim.override {
        # I use only Neovim
        viAlias = false;
        vimAlias = true;
      })
      # Required for some neovim tree-sitter parsers
      tree-sitter
      # Required to build some plugins (e.g. tree-sitter parsers)
      gcc

      # Required by some plugins
      nodejs
      # Required to install some Vim plugins that have helper programs written
      # in Node.js
      yarn

      ##########################################################################
      # Dev tools (formatters, linters, etc) that I use inside Neovim
      ##########################################################################
      yamllint
      # LSP based on tsserver
      nodePackages_latest.typescript-language-server
      nodePackages.eslint_d
      nodePackages.prettier
      nodePackages.stylelint

      # See
      # https://dlaa.me/blog/post/markdownlintcli2
      # for markdownlint-cli vs markdownlint-cli2
      #
      # But in the end I prefer markdownlint-cli because it supports
      # looking for a default config in $HOME
      # See https://github.com/igorshubovych/markdownlint-cli?tab=readme-ov-file#configuration
      # and https://github.com/DavidAnson/markdownlint-cli2/issues/364
      markdownlint-cli

      # Lua formatter
      stylua
      # Lua LSP
      lua-language-server
      # Lua linter
      lua53Packages.luacheck

      # clangd, clang-format, clang-tidy
      clang-tools_16
      # For `git-clang-format`
      libclang.python
      # Another language server for C/C++
      ccls
      cppcheck

      # CMake formatter
      cmake-format
      # CMake language server
      cmake-language-server

      # Nix LSP
      nil

      # Python tooling
      pyright
      black
      ruff

      # Assembly formatter
      asmfmt

      # Shell formatter and checker
      shfmt
      shellcheck

      # Nix formatter
      alejandra

      typst
      # Typst LSP
      tinymist
      # Typst formattero
      typstyle

      # JSON formatter
      fixjson

      # Rust tooling
      rust-analyzer
      clippy

      # SQL
      sqruff

      # Working with bibtex
      #
      # Nope. Were interesting options, but found something better.
      # fzf-bibtex
      # https://github.com/dimo414/bkt
      # bkt
      # https://github.com/typst/hayagriva
      # hayagriva
    ];
    file = {
      ".vim" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/vim/";
      };
      ".vimrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/vimrc";
      };
    };
  };
}

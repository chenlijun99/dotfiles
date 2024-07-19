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
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vim/";
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
      markdownlint-cli2

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

      # Python LSP
      pyright
      black

      # Assembly formatter
      asmfmt

      # Shell formatter and checker
      shfmt
      shellcheck

      # Nix formatter
      alejandra
    ];
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

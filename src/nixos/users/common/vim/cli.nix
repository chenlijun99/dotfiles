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
        viAlias = true;
        vimAlias = true;
      })
      # Required for some neovim tree-sitter parsers
      tree-sitter
      # Required to build some plugins (e.g. tree-sitter parsers)
      gcc

      ##########################################################################
      # Dev tools (formatters, linters, etc) that I use inside Neovim
      ##########################################################################
      yamllint
      # LSP based on tsserver
      nodePackages_latest.typescript-language-server
      nodePackages.eslint_d
      nodePackages.prettier
      nodePackages.stylelint
      nodePackages.markdownlint-cli

      # Lua formatter
      stylua
      # Lua LSP
      lua-language-server
      # Lua linter
      lua53Packages.luacheck

      # clangd, clang-format, clang-tidy
      clang-tools
      cppcheck

      # CMake formatter
      cmake-format
      # CMake language server
      cmake-language-server

      # Nix LSP
      rnix-lsp

      # Python LSP
      nodePackages_latest.pyright
      black

      # Assembly formatter
      asmfmt

      # Shell formatter and checker
      shfmt
      shellcheck
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

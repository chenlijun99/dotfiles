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
      ".vim" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vim/";
      };
      ".vimrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/vimrc";
      };
    };
  };
}

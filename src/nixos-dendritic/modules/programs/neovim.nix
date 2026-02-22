{...}: let
  systemConfigModule = {pkgs, ...}: {
    environment.systemPackages = [pkgs.vim];
    environment.variables.EDITOR = "vim";
  };
in {
  flake.modules.nixos.clj-neovim = systemConfigModule;
  flake.modules.darwin.clj-neovim = systemConfigModule;
  flake.modules.homeManager.clj-neovim = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.clj.programs.neovim = {
      enable = lib.mkEnableOption "Neovim editor" // {default = true;};
      gui.enable = lib.mkEnableOption "Neovim GUI" // {default = true;};
    };

    config = lib.mkIf config.clj.programs.neovim.enable {
      xdg.configFile = {
        "nvim" = {
          source = config.lib.clj.linkDotfile "src/vim/";
        };
      };

      home = {
        file = {
          ".vim" = {
            source = config.lib.clj.linkDotfile "src/vim/";
          };
          ".vimrc" = {
            source = config.lib.clj.linkDotfile "src/vimrc";
          };
        };

        packages =
          # Core neovim and dev tools (always)
          (with pkgs; [
            (neovim.override {
              viAlias = false;
              vimAlias = true;
            })
            tree-sitter
            gcc
            nodejs
            yarn
            fzf

            # Dev tools (formatters, linters, LSPs)
            yamllint
            nodePackages_latest.typescript-language-server
            nodePackages.eslint_d
            nodePackages.prettier
            nodePackages.stylelint
            markdownlint-cli
            stylua
            lua-language-server
            lua53Packages.luacheck
            clang-tools
            libclang.python
            ccls
            cppcheck
            cmake-format
            cmake-language-server
            nil
            pyright
            black
            ruff
            asmfmt
            shfmt
            shellcheck
            alejandra
            typst
            tinymist
            typstyle
            fixjson
            rust-analyzer
            clippy
            sqruff
          ])
          # GUI tools
          ++ lib.optionals ((config.clj.programs.neovim.gui.enable or false) && !pkgs.stdenv.isDarwin) (with pkgs; [
            xclip
            wl-clipboard
          ]);
      };
    };
  };
}

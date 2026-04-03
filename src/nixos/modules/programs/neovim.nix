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
      profile = lib.mkOption {
        type = lib.types.enum ["minimal" "full"];
        default = "minimal";
        description = ''
          Neovim profile to activate.
          - minimal: core editing, navigation, git, fuzzy find — suitable for remote servers.
          - full: all plugins including LSP, completion, AI, debugger, treesitter, etc.
          The profile is written to ''${XDG_STATE_HOME}/nvim/profile and read at Neovim startup.
          It can be overridden at runtime via the NVIM_PROFILE environment variable.
        '';
      };
    };

    config = lib.mkIf config.clj.programs.neovim.enable {
      xdg.configFile = {
        "nvim" = {
          source = config.lib.clj.linkDotfile "src/vim/";
        };
      };

      # Persist the selected profile so Neovim reads it at startup
      home.file.".local/state/nvim/profile".text = config.clj.programs.neovim.profile;

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
          # Core packages — always present regardless of profile
          (with pkgs; [
            (neovim.override {
              viAlias = false;
              vimAlias = true;
            })
            fzf
          ])
          # Full-profile packages: heavy dev toolchain (LSPs, formatters, linters, build tools)
          ++ lib.optionals (config.clj.programs.neovim.profile == "full") (with pkgs; [
            # What to keep here:
            # Tools that my neovim setup typically needs, outside of a project.
            # E.g., I edit markdown, shell, python, etc. everywhere, not only
            # in specific projects. So they should stay here.
            #
            # Other tools (LSPs, linters, etc) should be defined in project-specific nix shells
            # This may be needed to build tree-sitter grammars
            tree-sitter
            gcc
            # Some vim plugins may need this during installation
            nodejs
            yarn
            markdownlint-cli
            # Nix
            alejandra
            nil
            # Python
            ty
            ruff
            # Shell
            shfmt
            shellcheck
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

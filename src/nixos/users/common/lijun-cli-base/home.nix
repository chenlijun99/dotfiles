# "lijun-cli-base" contains everything that I normally use in the terminal
{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  imports = [
    ./tmux.nix
    ./shell.nix
    ./nix.nix
    ./opencode.nix
    ../this.nix
    ../vim/cli.nix
    ../networking/cli.nix
    ../performance/cli.nix
    # My custom scripts
    ./../../../../local/bin/scripts.nix
  ];
  home = {
    # See https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
    stateVersion = "21.11";
    packages = with pkgs; [
      git
      git-lfs
      wget
      file
      tldr
      htop
      vifm
      tree
      fzf
      # Ripgrep. I use it in Vim and also on CLI
      ripgrep
      # Temporarily disable doInstallCheck, which fails due to newest pandoc removing support for a flag
      # See https://discourse.nixos.org/t/ripgrep-all-build-error-on-latest-unstable/31907/3
      (ripgrep-all.overrideAttrs (old: {
        doInstallCheck = false;
      }))
      ##########################################################################
      # Dev tools
      ##########################################################################
      # C/C++ debuggers
      gdb
      lldb
      # I need `ts` from this package.
      moreutils
      # Useful for working with JSON on the commandline
      jq
      rclone
      devenv

      plantuml
      graphviz
      doxygen
      pandoc

      # terminal emulators that I use to interface with serial port

      # Count lines of code
      scc
    ];
    file = {
      ".vifm" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/vifm";
      };
      ".ctags" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/ctags";
      };
      ".detoxrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/detoxrc";
      };
      ".gdbinit" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/gdbinit";
      };
      ".gitconfig" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/gitconfig";
      };
      ".ls_colors" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/ls_colors";
      };
      ".markdownlint.jsonc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/markdownlint.jsonc";
      };
      ".markdownlintrc" = let
        stripJsoncCommentsNaive = inputPath: let
          drv = pkgs.stdenv.mkDerivation {
            name = "jsonc-to-json" + inputPath;
            src = inputPath;
            dontUnpack = true;
            buildInputs = [pkgs.jq];
            buildPhase = ''
              mkdir -p $out
              # Use jq to validate and format the JSON
              sed -E 's/\/\/.*$//' $src | jq > $out/output.json
            '';
          };
        in (drv + "/output.json");
      in {
        source = stripJsoncCommentsNaive ../../../../markdownlint.jsonc;
      };
      ".xbindkeysrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/xbindkeysrc";
      };
      # GNU readline config
      # Mostly for Vim keybindings
      ".inputrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/inputrc";
      };
    };
  };
  # Enable management of XDG base directories using home-manager
  xdg.enable = true;
}

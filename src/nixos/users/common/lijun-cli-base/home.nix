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
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./tmux.nix
    ./vim.nix
    ./shell.nix
    ../this.nix
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
}

# Shell configuration
{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  home = {
    packages = with pkgs; [
      zsh
      # normal bash causes several errors with my legacy bash config
      #
      # Something like:
      #
      # ```
      # ...
      # bash: complete: command not found
      # bash: shopt: hostcomplete: invalid shell option name
      # ...
      # ```
      bashInteractive
    ];
    file = {
      ".profile" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/profile";
      };
      ".shell_aliases" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/shell_aliases";
      };
      ##########################################################################
      # Zsh
      ##########################################################################
      ".zprofile" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/zprofile";
      };
      ".zshrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/zshrc";
      };
      ".on-my-zsh" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/oh-my-zsh";
        # Dunno why, but for ".oh-my-zsh" we need to set target
        target = ".oh-my-zsh";
      };
      ".zsh_custom" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/zsh_custom";
      };
      # Blazing fast prompt for Zsh
      ".p10k.zsh" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/p10k.zsh";
      };
      ##########################################################################
      # Bash (legacy stuff that I don't use anymore, since I use Zsh)
      ##########################################################################
      ".bashrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/bashrc";
      };
      ".promptrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/promptrc";
      };
      ".git-prompt.sh" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/git-prompt.sh";
      };
    };
  };
}

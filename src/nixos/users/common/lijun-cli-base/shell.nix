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
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/profile";
      };
      ".shell_aliases" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/shell_aliases";
      };
      ##########################################################################
      # Zsh
      ##########################################################################
      ".zprofile" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/zprofile";
      };
      ".zshrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/zshrc";
      };
      ".on-my-zsh" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/oh-my-zsh";
        # Dunno why, but for ".oh-my-zsh" we need to set target
        target = ".oh-my-zsh";
      };
      ".zsh_custom" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/zsh_custom";
      };
      # Blazing fast prompt for Zsh
      ".p10k.zsh" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/p10k.zsh";
      };
      ##########################################################################
      # Bash (legacy stuff that I don't use anymore, since I use Zsh)
      ##########################################################################
      ".bashrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/bashrc";
      };
      ".promptrc" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/promptrc";
      };
      ".git-prompt.sh" = {
        source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/git-prompt.sh";
      };
    };
  };
}

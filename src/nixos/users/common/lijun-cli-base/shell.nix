# Shell configuration
{
  config,
  pkgs,
  ...
}: {
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
      # Used for bash prompt
      starship
    ];
    file = {
      ".profile" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/profile";
      };
      ".shell_aliases" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/shell_aliases";
      };
      ".shell_env" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/shell_env";
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
      ".zimrc" = {
        source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/zimrc";
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
    };
  };
}

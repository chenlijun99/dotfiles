# Shell configuration
{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  home = {
    packages = with pkgs; [
      zsh
      bash
    ];
    file = {
      "profile" = {
        source = ../../../../profile;
        target = ".profile";
      };
      "shell_aliases" = {
        source = ../../../../shell_aliases;
        target = ".shell_aliases";
      };
      ##########################################################################
      # Zsh
      ##########################################################################
      "zprofile" = {
        source = ../../../../zprofile;
        target = ".zprofile";
      };
      "zshrc" = {
        source = ../../../../zshrc;
        target = ".zshrc";
      };
      "on-my-zsh" = {
        source = ../../../../oh-my-zsh;
        target = ".oh-my-zsh";
      };
      "zsh_custom" = {
        source = ../../../../zsh_custom;
        target = ".zsh_custom";
      };
      # Blazing fast prompt for Zsh
      "p10k.zsh" = {
        source = ../../../../p10k.zsh;
        target = ".p10k.zsh";
      };
      ##########################################################################
      # Bash (legacy stuff that I don't use anymore, since I use Zsh)
      ##########################################################################
      "bashrc" = {
        source = ../../../../bashrc;
        target = ".bashrc";
      };
      "promptrc" = {
        source = ../../../../promptrc;
        target = ".promptrc";
      };
      "git-prompt" = {
        source = ../../../../git-prompt.sh;
        target = ".git-prompt.sh";
      };
    };
  };
}

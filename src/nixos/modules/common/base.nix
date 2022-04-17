#
# Base packages that all users can use
#
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget
    git
    git-lfs
    tldr
    htop
    vifm
    # To support neovim clipboard
    xclip
    # Required for some neovim tree-sitter parsers
    tree-sitter
    neovim
    # Nix formatter
    alejandra
    home-manager
  ];
  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

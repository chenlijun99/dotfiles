#
# Base packages that all users can use
#
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  # Some IMHO essential packages that can be useful on any machine, to all users
  environment.systemPackages = with pkgs; [
    ############################################################################
    # Nix related
    ############################################################################
    # Nix formatter
    alejandra
    home-manager
    # Fast nix documentation
    manix

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
  ];
  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

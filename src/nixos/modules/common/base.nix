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
    # Needed for pkgs.breakpointhook
    # https://nixos.org/manual/nixpkgs/stable/#breakpointhook
    cntr

    wget
    file
    git
    git-lfs
    tldr
    htop
    vifm
    unzip

    lm_sensors

    ############################################################################
    # Neovim
    ############################################################################
    vim
    # To support neovim clipboard
    xclip
    wl-clipboard
  ];
  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

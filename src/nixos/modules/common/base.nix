#
# Base packages that all users can use
#
{
  pkgs,
  inputs,
  ...
}: {
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
    zip
    tree

    lm_sensors
    usbutils

    # Every system deserves a vim
    vim
  ];
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

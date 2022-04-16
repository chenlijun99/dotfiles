#
# Basic development tools that all the users can use
#
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    cmake
    ninja
    gnumake
    # Always have a C/C++ compiler at hand :)
    gcc
    # Languages runtimes
    nodejs
    python38
    # Package manager from Rust
    cargo
    # Main browser that all the users can use
    firefox
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

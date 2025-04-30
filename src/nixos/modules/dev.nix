#
# Basic development tools that all the users can use
#
{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cmake
    ninja
    gnumake
    # bear can be used to get a `compile_commands.json` file out from a Makefile-based project
    bear
    # Always have a C/C++ compiler at hand :)
    gcc
    # Languages runtimes
    nodejs
    python3Full
    lua
    # Package manager from Rust
    cargo

    man-pages
    man-pages-posix
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

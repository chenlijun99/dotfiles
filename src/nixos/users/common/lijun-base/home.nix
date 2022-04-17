# "lijun-base" contains everything that I normally use to work, excluding
# stuff such as note taking, messaging, etc.
{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  home = {
    # See https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
    stateVersion = "21.11";
    packages = with pkgs; [
      tmux
      # For tmux-yank
      xsel
      # Ripgrep. I use it in Vim and also on CLI
      ripgrep
      ripgrep-all
      # My terminal of choice
      alacritty
      fzf
      # I never use it, but it may be useful
      vscode
      # Lightweight PDF reader
      zathura
      # For offline documentation 
      zeal
      # Screenshot tool
      flameshot
      # Disk usage statistics
      libsForQt5.filelight
      # Latex
      texlive.combined.scheme-medium
      ##
      # Dev tools (formatters, linters, etc)
      ##
      gdb
      # C/C++ debugger based on LLVM
      lldb
      clang_12
      # Yaml linter
      yamllint
      # Lua formatter
      stylua
      # Language server, clang-format, clang-tidy
      clang-tools
      # Assembly formatter
      asmfmt
      cmake-format
      shellcheck
      cppcheck
      lua53Packages.luacheck
      black
    ];
  };
}

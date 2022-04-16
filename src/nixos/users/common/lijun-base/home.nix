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
    ];
  };
}

#
# Configuration for my typical developmment environment
#
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs;
    [
      wget
      git
      git-lfs
      tmux
      fzf
      # Always have a C/C++ compiler at hand :)
      gcc
      # To support neovim clipboard
      xclip
      # For tmux-yank
      xsel
      # Ripgrep. I use it in Vim and also on CLI
      ripgrep
      ripgrep-all
      # My terminal of choice
      alacritty
      # Email client
      thunderbird
      # Main browser
      firefox
      # A second browser is always useful
      chromium
      # Citation manager
      zotero
      # Note taking app
      obsidian
      # I never use it, but it may be useful
      vscode
    ]
    ++ (let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = pkgs.system;
        overlays = [
          (final: prev: {
            neovim = prev.neovim.override {
              viAlias = true;
              vimAlias = true;
            };
          })
        ];
      };
    in [
      pkgs-unstable.neovim
      # Nix formatter
      pkgs-unstable.alejandra
    ]);
  environment.variables.EDITOR = "nvim";

  # Install fonts
  fonts.fonts = with pkgs; [
    # My Alacritty config uses NerdFont patched Hack
    (nerdfonts.override {fonts = ["Hack"];})
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}

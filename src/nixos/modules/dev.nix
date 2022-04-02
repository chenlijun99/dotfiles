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
      tldr
      cmake
      ninja
      gnumake
      # Always have a C/C++ compiler at hand :)
      gcc
      # Languages runtimes
      nodejs
      python38
      # Email client
      thunderbird
      # Main browser
      firefox
      # A second browser is always useful
      chromium
      # Password manager
      keepassxc
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
      # To support neovim clipboard
      xclip
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

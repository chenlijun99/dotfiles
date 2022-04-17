#
# Base packages that all users can use
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
      htop
      vifm
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
      # Required for some neovim tree-sitter parsers
      tree-sitter
      pkgs-unstable.neovim
      # Nix formatter
      pkgs-unstable.alejandra
      # Nix-based Home manager
      pkgs-unstable.home-manager
    ]);
  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}


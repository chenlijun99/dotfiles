# Minimal preset
# Small shell tools and neovim
# For: Remote servers, minimal VMs
{self, ...}: let
  features = [
    "clj-lib"
    "clj-nix"
    "clj-shell"
    "clj-git"
    "clj-neovim"
    "clj-tmux"
    "clj-cli-utils"
    "clj-networking"
    "clj-ghostty"
  ];
  imports = self.lib.mkMultiContextImports features;
in {
  flake.modules.nixos.clj-preset-minimal = {lib, ...}: {
    imports = imports.nixos;
    config = {
      clj.programs.ghostty.enable = lib.mkDefault false;
      clj.programs.ghostty.include_terminfo = lib.mkDefault true;
    };
  };

  flake.modules.darwin.clj-preset-minimal = {lib, ...}: {
    imports = imports.darwin;
    config.clj.programs.ghostty.enable = lib.mkDefault false;
  };

  flake.modules.homeManager.clj-preset-minimal = {lib, ...}: {
    imports = imports.homeManager;
    config = {
      clj.programs.networking.gui.enable = lib.mkDefault false;
      clj.programs.neovim.profile = lib.mkDefault "minimal";
      clj.programs.ghostty.enable = lib.mkDefault false;
    };
  };
}

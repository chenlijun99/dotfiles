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
  ];
  imports = self.lib.mkMultiContextImports features;
in {
  flake.modules.nixos.clj-preset-minimal = {lib, ...}: {
    imports = imports.nixos;
  };

  flake.modules.darwin.clj-preset-minimal = {lib, ...}: {
    imports = imports.darwin;
  };

  flake.modules.homeManager.clj-preset-minimal = {lib, ...}: {
    imports = imports.homeManager;
    config = {
      clj.programs.networking.gui.enable = lib.mkDefault false;
    };
  };
}

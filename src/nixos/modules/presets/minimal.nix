# Minimal preset
# Familiar shell and basic tools without development tooling
# For: Remote servers, service VMs, administrative accounts
{self, ...}: let
  features = [
    # Used by other modules
    "clj-lib"
    "clj-impermanence"
    # Independent
    "clj-nix"
    "clj-users"
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
      clj.programs.ghostty.enable = lib.mkDefault false;
    };
  };
}

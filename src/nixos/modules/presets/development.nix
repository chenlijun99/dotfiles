# Development preset
# Familiar shell and development tooling, without desktop applications
# For: Development containers and VMs
{self, ...}: let
  featureImports = self.lib.mkMultiContextImports [
    "clj-devenv"
    "clj-codex"
  ];
in {
  flake.modules.nixos.clj-preset-development = {...}: {
    imports =
      [self.modules.nixos.clj-preset-minimal]
      ++ featureImports.nixos;
  };

  flake.modules.darwin.clj-preset-development = {...}: {
    imports =
      [self.modules.darwin.clj-preset-minimal]
      ++ featureImports.darwin;
  };

  flake.modules.homeManager.clj-preset-development = {lib, ...}: {
    imports =
      [self.modules.homeManager.clj-preset-minimal]
      ++ featureImports.homeManager;

    config.clj.programs.neovim.profile = lib.mkDefault "full";
  };
}

# Helper for importing features across multiple contexts without duplication
#
# Problem: Features can define modules for nixos, darwin, and homeManager.
# When creating presets, you have to manually check which contexts each feature
# supports and import them separately in each context block.
#
# Solution: This helper takes a list of feature names and returns an attrset
# with imports for each context that the features support.
#
# Usage:
#   let
#     featureImports = self.lib.mkMultiContextImports ["clj-shell" "clj-ghostty" "clj-neovim"];
#   in {
#     flake.modules.nixos.clj-my-preset = {
#       imports = featureImports.nixos;
#     };
#     flake.modules.darwin.clj-my-preset = {
#       imports = featureImports.darwin;
#     };
#     flake.modules.homeManager.clj-my-preset = {
#       imports = featureImports.homeManager;
#     };
#   }
{
  self,
  lib,
  ...
}: {
  config.flake.lib.mkMultiContextImports = featureNames: let
    # For each context, collect all features that define modules for that context
    collectForContext = context:
      lib.filter (x: x != null) (
        map (name:
          if lib.hasAttr context self.modules && lib.hasAttr name self.modules.${context}
          then self.modules.${context}.${name}
          else null)
        featureNames
      );
  in {
    nixos = collectForContext "nixos";
    darwin = collectForContext "darwin";
    homeManager = collectForContext "homeManager";
  };
}

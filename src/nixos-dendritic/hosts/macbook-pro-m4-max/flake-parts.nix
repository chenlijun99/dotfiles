# MacBook Pro M4 Max
{
  inputs,
  self,
  ...
}: let
  hostName = "MAC9004";
  features = [
    "clj-ghostty"
    "clj-kanata"
  ];
  imports = self.lib.mkMultiContextImports features;
in {
  flake.darwinConfigurations.${hostName} =
    inputs.nix-darwin.lib.darwinSystem
    {
      system = "aarch64-darwin";
      modules = let
        userLijun = self.lib.mkUser "lijun.chen" {
          homeManager = {
            imports =
              [
                self.modules.homeManager.clj-preset-minimal
                {
                  clj.dotfiles.editable = true;
                }
              ]
              ++ imports.homeManager;
            home.stateVersion = "25.11";
          };
        };
      in [
        ({
          pkgs,
          lib,
          ...
        }: {
          imports = with self.modules.darwin;
            [
              clj-preset-minimal
              userLijun.darwinModule
            ]
            ++ imports.darwin;
          nixpkgs.config.allowUnfree = true;
          # Add my user to trusted-users to be able to specify builders
          # E.g., use Linux VM as remote-builder for Linux VM.
          nix.settings.trusted-users = ["root" "lijun.chen"];

          system.stateVersion = 6;
          system.defaults = {
            dock = {
              autohide = true;
              persistent-apps = [
                {app = "/Applications/Island.app";}
                {app = "/Applications/Ghostty.app";}
                {app = "/Applications/Slack.app";}
              ];
            };
          };

          homebrew = {
            enable = true;
            # Optional: removes unlisted packages
            # Naaaa, a bit of statefulness is good (yeah, it's me being lazy)
            # onActivation.cleanup = "zap";
          };

          system.primaryUser = "lijun.chen";
          home-manager.users."lijun.chen" = {
            home = {
              sessionVariables = {
                CODECOMPANION_CHAT_ADAPTER = "copilot_claude-sonnet-4.5";
                CODECOMPANION_INLINE_ADAPTER = "copilot_claude-sonnet-4.5";
              };
            };
          };
        })
      ];
    };
}

#
# Nix-darwin config for running on a MacBook Pro M4 Max
#
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./kanata.nix
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

  nix = {
    # Manage nix using nix-darwin. This replaces the default nix (lix)
    # executable that comes with the Lix installer.
    enable = true;
    extraOptions = ''
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };
  nixpkgs.flake.setFlakeRegistry = true;

  system.defaults = {
    dock = {
      autohide = true;
      persistent-apps = [
        {
          app = "/Applications/Island.app";
        }
        {
          app = "/Applications/Ghostty.app";
        }
        {
          app = "/Applications/Slack.app";
        }
      ];
    };
    # Trackpad: tap to click
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  };

  environment.systemPackages = with pkgs; [
    # GNU coreutils
    coreutils
  ];

  users.users."lijun.chen" = {
    home = "/Users/lijun.chen";
    shell = pkgs.zsh;
  };
  system.primaryUser = "lijun.chen";

  homebrew = {
    enable = true;
    # Optional: removes unlisted packages
    onActivation.cleanup = "zap";
    casks = [
      # On macOS, to get the ghostty prerelease versions, we can only use
      # homebrew.
      # See https://ghostty.org/docs/install/pre#macos
      # The `ghostty-bin` package on Nixpkgs as for now doesn't have the
      # features I need.
      "ghostty@tip"
    ];
  };

  home-manager.users."lijun.chen" = {
    imports = [
      ../../users/lijun-cli/home.nix
      ../../users/common/lijun-base/ghostty.nix
    ];
    home = {
      username = lib.mkForce "lijun.chen";
      homeDirectory = lib.mkForce "/Users/lijun.chen";
      sessionVariables = {
        CODECOMPANION_CHAT_ADAPTER = "copilot_claude-sonnet-4.5";
        CODECOMPANION_INLINE_ADAPTER = "copilot_claude-sonnet-4.5";
      };
    };
  };
}

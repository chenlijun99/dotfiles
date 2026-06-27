# Desktop environment configuration (KDE Plasma)
{inputs, ...}: {
  flake.modules.nixos.clj-desktop-environment = {
    services.displayManager.sddm.enable = true;
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.libinput.enable = true;

    # Fixes https://github.com/NixOS/nixpkgs/issues/145354
    xdg.portal = {
      xdgOpenUsePortal = true;
      enable = true;
    };
  };

  flake.modules.darwin.clj-desktop-environment = {
    system.defaults = {
      dock.autohide = true;
      NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    };
  };

  flake.modules.homeManager.clj-desktop-environment = {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
      ({config, ...}: {
        home.persistence.${config.clj.impermanence.persistDir} = {
          files = [
            # Display configuratino of KDE
            ".config/kwinoutputconfig.json"
          ];
        };
      })
      ./_plasma-manager.nix
    ];
  };
}

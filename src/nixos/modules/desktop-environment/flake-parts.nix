# Desktop environment configuration (KDE Plasma)
{inputs, ...}: let
  home-manager = {
    sharedModules = [inputs.plasma-manager.homeModules.plasma-manager];
  };
in {
  flake.modules.nixos.clj-desktop-environment = {
    inherit home-manager;

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
    inherit home-manager;

    system.defaults = {
      dock.autohide = true;
      NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    };
  };

  flake.modules.homeManager.clj-desktop-environment = {
    imports = [
      ./_plasma-manager.nix
    ];
  };
}

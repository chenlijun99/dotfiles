{self, ...}: {
  flake.modules.nixos.clj-ghostty = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.clj.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator" // {default = true;};
    # Sometimes we don't want to use ghostty on a machine, but we want to support
    # people using ghostty to SSH into the machine.
    # See https://ghostty.org/docs/help/terminfo#ssh
    options.clj.programs.ghostty.include_terminfo = lib.mkEnableOption "Include ghostty terminfo into the system" // {default = config.clj.programs.ghostty.enable;};

    config = lib.mkIf config.clj.programs.ghostty.include_terminfo {
      environment.systemPackages = with pkgs; [
        ghostty.terminfo
      ];
    };
  };

  # Darwin uses Homebrew for the latest tip release
  flake.modules.darwin.clj-ghostty = {
    config,
    lib,
    ...
  }: {
    options.clj.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator" // {default = true;};

    config = lib.mkIf config.clj.programs.ghostty.enable {
      homebrew.casks = [
        "ghostty@tip"
      ];
    };
  };

  # Home-Manager config (shared config, package only on non-Darwin)
  flake.modules.homeManager.clj-ghostty = {
    pkgs,
    config,
    lib,
    ...
  }: let
    clipboardNormalizer = pkgs.writers.writePython3Bin "wayland-clipboard-normalizer" {} (
      builtins.readFile ./ghostty-clipboard-normalizer.py
    );
  in {
    options.clj.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator" // {default = true;};
    options.clj.programs.ghostty.normalizeClipboard =
      lib.mkEnableOption "republish Codex clipboard entries through Wayland" // {default = true;};

    config = lib.mkIf config.clj.programs.ghostty.enable {
      # Only install the package on non-Darwin (Darwin uses homebrew)
      home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [
        pkgs.ghostty
      ];
      # Work around Codex's broken Wayland clipboard target set. The full bug,
      # workarounds, tradeoff, and upstream links are documented in
      # ghostty-clipboard-normalizer.py.
      systemd.user.services.wayland-clipboard-normalizer =
        lib.mkIf
        (!pkgs.stdenv.hostPlatform.isDarwin && config.clj.programs.ghostty.normalizeClipboard) {
          Unit = {
            Description = "Republish Codex text copies through Wayland";
            After = ["graphical-session.target"];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };
          Service = {
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text/plain --watch ${clipboardNormalizer}/bin/wayland-clipboard-normalizer";
            Environment = [
              "WL_PASTE=${pkgs.wl-clipboard}/bin/wl-paste"
              "WL_COPY=${pkgs.wl-clipboard}/bin/wl-copy"
            ];
            Restart = "always";
            RestartSec = 2;
          };
          Install.WantedBy = ["graphical-session.target"];
        };
      programs.ghostty = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
        enable = true;

        # This enables the systemd user service (app-com.mitchellh.ghostty.service)
        # which allows for faster launching and background persistence.
        # Without this, the desktop file of ghostty, which has
        # `DBusActivatable=true`, won't work.
        # dbus will complain something like 'Activation via systemd failed for unit
        # 'app-com.mitchellh.ghostty.service': Unit
        # app-com.mitchellh.ghostty.service not found.
        #
        # And setting `DBusActivatable=false` is not the right fix (see
        # https://github.com/ghostty-org/ghostty/discussions/10617#discussioncomment-16424746).
        # Properly configuring systemd unit file is
        systemd.enable = true;

        # No settings. I manage settings via normal ghostty config files
        # settings = { };
      };
      xdg.configFile = {
        "ghostty_config" = {
          source = config.lib.clj.linkDotfile "src/config/ghostty/config";
          target = "ghostty/config";
        };
        "ghostty_gtk_css" = {
          source = config.lib.clj.linkDotfile "src/config/ghostty/gtk.css";
          target = "ghostty/gtk.css";
        };
        "ghostty_config_platform" = {
          source = config.lib.clj.linkDotfile (
            if pkgs.stdenv.hostPlatform.isDarwin
            then "src/config/ghostty/config_macos"
            else "src/config/ghostty/config_linux"
          );
          target = "ghostty/config_platform";
        };
      };
    };
  };
}

# Full preset
# Everything including GUI apps for daily driver
# For: Personal workstations, main desktop/laptop
{self, ...}: let
  featureImports = self.lib.mkMultiContextImports [
    "clj-lib"
    "clj-nix"
    "clj-shell"
    "clj-cli-utils"
    "clj-ghostty"
    "clj-neovim"
    "clj-tmux"
    "clj-git"
    "clj-networking"
    "clj-desktop-environment"
    "clj-firefox"
    "clj-input-method"
    "clj-fonts"
    "clj-zotero"
    "clj-container"
    "clj-kanata"
    "clj-ai"
    "clj-personal-scripts"
  ];
in {
  # NixOS system-level configuration for personal preset
  flake.modules.nixos.clj-preset-full = {
    pkgs,
    lib,
    ...
  }: {
    imports = featureImports.nixos;

    config = {
      # Audio
      services.pipewire.enable = true;

      # Printing
      services.printing.enable = true;
      # Graphic tablet
      hardware.opentabletdriver.enable = true;
      services.flatpak.enable = true;
    };
  };

  # Darwin system-level configuration for personal preset
  flake.modules.darwin.clj-preset-full = {
    pkgs,
    lib,
    ...
  }: {
    imports = featureImports.darwin;
  };

  # Home-Manager configuration for personal preset
  flake.modules.homeManager.clj-preset-full = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.clj.preset.full;
  in {
    imports =
      featureImports.homeManager;

    options.clj.preset.full = {
      personal-applications.enable = lib.mkEnableOption "Personal applications (LibreOffice, Anki, etc.)" // {default = true;};
      communication.enable = lib.mkEnableOption "Communication apps (Slack, Signal, Zoom, etc.)" // {default = true;};
      browsers.enable = lib.mkEnableOption "Web browsers (Firefox, Chromium)" // {default = true;};
      utilities.enable = lib.mkEnableOption "GUI utilities (GParted, Calculator, etc.)" // {default = true;};
      multimedia.enable = lib.mkEnableOption "Multimedia apps (VLC, OBS, Inkscape, etc.)" // {default = true;};
      services.enable = lib.mkEnableOption "Background services (ActivityWatch, Syncthing)" // {default = true;};
    };

    config = lib.mkMerge [
      # Zotero config
      {
        clj.programs.zotero.profiles.default = {
          id = 0;
          isDefault = true;
        };
      }

      # Communication packages
      (lib.mkIf cfg.communication.enable {
        home.packages = with pkgs; [
          # Email
          thunderbird
          # Messaging
          slack
          signal-desktop
          telegram-desktop
          discord
        ];
      })

      # Browsers
      (lib.mkIf cfg.browsers.enable {
        home.packages = with pkgs; [
          chromium
        ];
        clj.programs.firefox.enable = true;
      })

      # GUI utilities
      (lib.mkIf cfg.utilities.enable {
        home.packages = with pkgs; [
          gparted
          gnome-disk-utility
          gnome-calculator
          kdePackages.filelight
        ];
      })

      # Personal applications
      (lib.mkIf cfg.personal-applications.enable {
        home.packages = with pkgs; [
          kdePackages.okular
          xournalpp
          anki-bin
          keepassxc
          pcloud
          nextcloud-client
          cryptomator
          gtkterm
          zathura
          zeal
        ];

        xdg.configFile = {
          "zathura" = {
            source = config.lib.clj.linkDotfile "src/config/zathura";
          };
        };
      })

      # Multimedia apps
      (lib.mkIf cfg.multimedia.enable {
        home.packages = with pkgs; [
          strawberry
          ffmpeg
          vlc
          obs-studio
          inkscape
          digikam
          kdePackages.skanlite
          kdePackages.skanpage
          imagemagickBig
          scrcpy
          kdePackages.krecorder
          gnome-pomodoro
          safeeyes
        ];

        xdg.configFile = {
          "strawberry" = {
            source = config.lib.clj.linkDotfile "src/config/strawberry";
          };
          "safeeyes" = {
            source = config.lib.clj.linkDotfile "src/config/safeeyes";
          };
        };
      })

      # Background services
      (lib.mkIf cfg.services.enable {
        services.activitywatch = {
          enable = true;
        };

        services.syncthing = {
          enable = true;
          tray.enable = true;
        };
      })
    ];
  };
}

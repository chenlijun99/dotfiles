# Full preset
# Development plus GUI and personal workstation software
# For: Personal workstations, main desktop/laptop
{self, ...}: let
  featureImports = self.lib.mkMultiContextImports [
    "clj-desktop-environment"
    "clj-firefox"
    "clj-keepassxc"
    "clj-keyring"
    "clj-input-method"
    "clj-fonts"
    "clj-zotero"
    "clj-container"
    "clj-kanata"
    "clj-opencode"
    "clj-voxtype"
    "clj-personal-scripts"
  ];
in {
  # NixOS system-level configuration for personal preset
  flake.modules.nixos.clj-preset-full = {lib, ...}: {
    imports =
      [self.modules.nixos.clj-preset-development]
      ++ featureImports.nixos;

    config = {
      clj.programs.ghostty.enable = lib.mkOverride 500 true;

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
  flake.modules.darwin.clj-preset-full = {lib, ...}: {
    imports =
      [self.modules.darwin.clj-preset-development]
      ++ featureImports.darwin;

    config.clj.programs.ghostty.enable = lib.mkOverride 500 true;
  };

  # Home-Manager configuration for personal preset
  flake.modules.homeManager.clj-preset-full = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports =
      [self.modules.homeManager.clj-preset-development]
      ++ featureImports.homeManager;

    config = {
      clj.programs = {
        ghostty.enable = lib.mkOverride 500 true;
        networking.gui.enable = lib.mkOverride 500 true;
      };

      # Zotero config
      clj.programs.zotero.profiles.default = {
        id = 0;
        isDefault = true;
      };

      home = {
        persistence.${config.clj.impermanence.persistDir} = {
          directories = [
            {
              directory = ".local/share/TelegramDesktop";
              mode = "0700";
            }
            {
              directory = ".thunderbird";
              mode = "0700";
            }
            {
              directory = ".cache/thunderbird";
              mode = "0700";
            }
            {
              directory = ".config/pcloud";
              mode = "0700";
            }
            {
              directory = ".pcloud";
              mode = "0700";
            }
          ];
        };

        packages = with pkgs; [
          # Email
          thunderbird
          # Messaging
          slack
          signal-desktop
          telegram-desktop
          discord
          # Browser
          chromium
          # GUI utilities
          gparted
          gnome-disk-utility
          gnome-calculator
          kdePackages.filelight
          # Personal applications
          kdePackages.okular
          xournalpp
          anki-bin
          pcloud
          nextcloud-client
          cryptomator
          gtkterm
          zathura
          zeal
          # Multimedia
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
      };

      xdg.configFile = {
        "zathura" = {
          source = config.lib.clj.linkDotfile "src/config/zathura";
        };
        "strawberry" = {
          source = config.lib.clj.linkDotfile "src/config/strawberry";
        };
        "safeeyes" = {
          source = config.lib.clj.linkDotfile "src/config/safeeyes";
        };
      };

      services.syncthing = {
        enable = true;
        tray.enable = true;
      };
    };
  };
}

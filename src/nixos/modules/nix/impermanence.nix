# Impermanence integration
# Helps manage persistent state on systems with ephemeral root
{inputs, ...}: {
  flake.modules.nixos.clj-impermanence = {lib, ...}: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    # Common persistent directories for NixOS systems
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  flake.modules.homeManager.clj-impermanence = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.impermanence.nixosModules.home-manager.impermanence
    ];

    # Common persistent directories for home-manager
    # These are inferred from your current setup
    home.persistence."/persist${config.home.homeDirectory}" = {
      directories = [
        # Shell history
        ".local/share/zsh"
        ".bash_history"

        # SSH
        ".ssh"

        # GPG
        ".gnupg"

        # Git credentials
        ".config/git"

        # Development
        "Repositories"
        ".cargo"
        ".rustup"
        ".npm"
        ".cache/pip"

        # Application data
        ".mozilla/firefox"
        ".config/chromium"
        ".config/Code"
        ".config/obsidian"
        ".local/share/zotero"
        ".local/share/keepassxc"
        ".local/share/TelegramDesktop"
        ".config/Signal"
        ".config/Slack"
        ".config/discord"

        # Cloud sync
        ".config/Nextcloud"
        ".config/pcloud"
        ".local/share/syncthing"

        # KDE
        ".local/share/kwalletd"
        ".local/share/baloo"
        ".config/kdeconnect"

        # Media
        ".config/strawberry"
        ".local/share/strawberry"

        # Misc
        ".local/share/direnv"
      ];
      files = [
        ".zsh_history"
      ];
      allowOther = true;
    };
  };
}

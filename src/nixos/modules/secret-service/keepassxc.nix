# Some experiment code that records an attempt to use keepassxc as secret
# service provider.
{...}: {
  flake.modules.nixos.clj-keepassxc = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hmUsers = lib.attrByPath ["home-manager" "users"] {} config;
    enabledUsers = lib.attrNames (lib.filterAttrs (_name: hmCfg: lib.attrByPath ["clj" "keepassxc" "enable"] true hmCfg) hmUsers);
    kdeEnabled = config.services.desktopManager.plasma6.enable or false;
  in {
    config = lib.mkIf (enabledUsers != []) {
      # KeePassXC provides org.freedesktop.secrets and must run in user session.
      environment.systemPackages = [pkgs.keepassxc];

      # Disable KDE Wallet integration when KDE is enabled.
      environment.plasma6.excludePackages = lib.mkIf kdeEnabled (with pkgs.kdePackages; [
        kwallet
        kwallet-pam
        kwalletmanager
        signon-kwallet-extension
      ]);
      security.pam.services = lib.mkIf kdeEnabled {
        sddm.kwallet.enable = lib.mkForce false;
        login.kwallet.enable = lib.mkForce false;
        kde.kwallet.enable = lib.mkForce false;
      };
    };
  };

  flake.modules.homeManager.clj-keepassxc = {
    config,
    lib,
    pkgs,
    osConfig ? null,
    ...
  }: let
    cfg = config.clj.keepassxc;
    guiEnabled = osConfig.services.xserver.enable;
    # ssh-agent often starts before DISPLAY/WAYLAND variables are imported into
    # the systemd user manager. Fetch them dynamically at askpass time instead.
    sshAskPassWrapper = pkgs.writeShellScript "clj-ssh-askpass-wrapper" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      while IFS= read -r entry; do
        export "$entry"
      done < <(${pkgs.systemd}/bin/systemctl --user show-environment | ${lib.getExe pkgs.gnugrep} -E '^(DISPLAY|WAYLAND_DISPLAY|XAUTHORITY|SSH_ASKPASS)=')

      # Avoid recursion and provide a sane fallback askpass implementation.
      if [[ -z "''${SSH_ASKPASS:-}" || "''${SSH_ASKPASS}" == "$0" ]]; then
        exec ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass "$@"
      fi

      exec "''${SSH_ASKPASS}" "$@"
    '';
  in {
    options.clj.keepassxc.enable = lib.mkEnableOption "KeePassXC" // {default = true;};

    config = lib.mkIf cfg.enable {
      home.packages = [pkgs.keepassxc];

      # Enable ssh-agent to which keepassxc will add the SSH keys
      services.ssh-agent.enable = true;
      # Properly configure ssh-agent to use SSH_ASKPASS
      # https://github.com/keepassxreboot/keepassxc/issues/1627
      # https://github.com/nix-community/home-manager/issues/5194
      systemd.user.services.ssh-agent = lib.mkIf guiEnabled {
        Service = {
          # ssh-agent checks DISPLAY before invoking SSH_ASKPASS; any non-empty
          # value enables askpass. Real session vars are loaded by the wrapper.
          Environment = [
            "DISPLAY=fake"
            "SSH_ASKPASS=${sshAskPassWrapper}"
          ];
        };
      };

      xdg.configFile."keepassxc/keepassxc.ini".text = ''
        [General]
        ConfigVersion=2
        MinimizeOnStartup=true

        # Enable browser plugin integration
        [Browser]
        Enabled=true

        # Enable SSH agent integration
        [SSHAgent]
        Enabled=true

        # Enable Linux secret service integration
        [FdoSecrets]
        Enabled=true
      '';

      # Autostart keepassxc
      xdg.configFile."autostart/org.keepassxc.KeePassXC.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=KeePassXC
        Exec=${pkgs.keepassxc}/bin/keepassxc --minimized
        StartupNotify=false
        Terminal=false
        X-GNOME-Autostart-enabled=true
      '';
    };
  };
}

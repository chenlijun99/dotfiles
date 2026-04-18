# Some experiment code that records an attempt to use keepassxc as secret
# service provider.
{...}: {
  flake.modules.nixos.clj-keyring = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hmUsers = lib.attrByPath ["home-manager" "users"] {} config;
    enabledUsers = lib.attrNames (lib.filterAttrs (_name: hmCfg: lib.attrByPath ["clj" "keyring" "enable"] true hmCfg) hmUsers);
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

  flake.modules.homeManager.clj-keyring = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.clj.keyring;
  in {
    options.clj.keyring.enable = lib.mkEnableOption "KeePassXC keyring backend (Secret Service + browser integration)" // {default = true;};

    config = lib.mkIf cfg.enable {
      home.packages = [pkgs.keepassxc];

      xdg.configFile."keepassxc/keepassxc.ini".text = ''
        [General]
        ConfigVersion=2
        MinimizeOnStartup=true

        [Browser]
        Enabled=true

        [FdoSecrets]
        Enabled=true
      '';

      xdg.configFile."kwalletrc".text = ''
        [Wallet]
        Enabled=false
        First Use=false
      '';

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

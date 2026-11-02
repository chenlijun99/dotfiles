# KeePassXC supplies the SSH agent and browser integration. It does not provide
# org.freedesktop.secrets; oo7 owns that service.
{...}: {
  flake.modules.nixos.clj-keepassxc = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hmUsers = lib.attrByPath ["home-manager" "users"] {} config;
    enabledUsers = lib.attrNames (lib.filterAttrs (_name: hmCfg: lib.attrByPath ["clj" "keepassxc" "enable"] true hmCfg) hmUsers);
  in {
    config = lib.mkIf (enabledUsers != []) {
      environment.systemPackages = [pkgs.keepassxc];
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

      # This home-manager opion also takes care of seeting up browser
      # integration by configuring `nativeMessagingHosts` properly.
      programs.keepassxc = {
        enable = true;
        # See also settings in https://github.com/keepassxreboot/keepassxc/blob/develop/src/core/Config.cpp
        settings = {
          # Enable browser plugin integration
          Browser.Enabled = true;
          SSHAgent.Enabled = true;
          # oo7 is the only freedesktop Secret Service provider.
          FdoSecrets.Enabled = false;
        };
      };
    };
  };
}

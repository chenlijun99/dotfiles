# oo7 owns org.freedesktop.secrets and the Secret desktop portal. KeePassXC
# remains available for its SSH agent and browser integration only.
#
# PAM behavior and current nixpkgs limitations:
#
# * oo7 unlocks its login keyring from the account password supplied by PAM.
# * services.oo7 enables PAM for the `login` service. SDDM uses a substack of
#   `login`, so it inherits the integration without extra rules.
# * This module does not enable `security.pam.services.passwd.oo7.enable`.
#   Keep it disabled for now: nixpkgs issue #570569 reports that optional
#   modules in the passwd password stack are skipped because pam_unix is
#   currently `sufficient`.
#   https://github.com/NixOS/nixpkgs/issues/570569
# * `hashedPasswordFile` changes bypass PAM. With users.mutableUsers = false,
#   NixOS applies the new hash during activation, but the oo7 keyring remains
#   encrypted with the old password. Before logging out after such a change,
#   run `oo7-cli change-secret` and enter the new account password.
# * nixpkgs PR #544377 adds the missing passwd and display-manager integration.
#   Revisit these local comments once it is merged.
#   https://github.com/NixOS/nixpkgs/pull/544377
#
# Keyring contents are disposable. Losing or resetting the keyring is expected
# to require re-authenticating applications; durable credentials belong in
# KeePassXC.
{ ... }: {
  flake.modules.nixos.clj-keyring =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      kdeEnabled = config.services.desktopManager.plasma6.enable or false;
    in
    {
      services.oo7.enable = true;

      # The daemon can start before the graphical session environment has been
      # imported into the user manager. It uses this variable to select the
      # Plasma prompter for manual unlocks.
      # Without this, I experienced `oo7-cli unlock` getting stuck.
      systemd.user.services.oo7-daemon.serviceConfig.Environment = lib.mkIf kdeEnabled [
        "XDG_CURRENT_DESKTOP=KDE"
      ];

      # Make sure the portal selects oo7 even though oo7-portal.portal declares
      # UseIn=gnome. The daemon itself still provides org.freedesktop.secrets.
      xdg.portal = {
        enable = lib.mkDefault true;
        config.common."org.freedesktop.impl.portal.Secret" = lib.mkForce [ "oo7-portal" ];
      };

      # KWallet is a second Secret Service provider and must not run alongside
      # oo7. Exclude its packages and PAM hooks when Plasma is enabled.
      environment.plasma6.excludePackages = lib.mkIf kdeEnabled (
        with pkgs.kdePackages;
        [
          kwallet
          kwallet-pam
          kwalletmanager
          signon-kwallet-extension
        ]
      );
      security.pam.services = lib.mkIf kdeEnabled {
        login.kwallet.enable = lib.mkForce false;
        sddm.kwallet.enable = lib.mkForce false;
        kde.kwallet.enable = lib.mkForce false;
      };

      # Changing hashedPasswordFile under users.mutableUsers = false changes the
      # account password without invoking PAM. Warn while the old oo7 session is
      # still unlocked so the user can re-encrypt the keyring before logout.
      system.activationScripts =
        lib.mkIf
          (!config.users.mutableUsers && !config.systemd.sysusers.enable && !config.services.userborn.enable)
          {
            oo7PasswordChangeWarning = {
              supportsDryActivation = true;
              text =
                let
                  passwordFileUsers = lib.filterAttrs (
                    _name: user: user.hashedPasswordFile != null
                  ) config.users.users;
                in
                lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (name: user: ''
                    currentHash="$(${pkgs.gawk}/bin/awk -F: -v user=${lib.escapeShellArg name} '$1 == user { print $2; exit }' /etc/shadow 2>/dev/null || true)"
                    configuredHash="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg user.hashedPasswordFile} 2>/dev/null || true)"

                    if [[ -n "$currentHash" && "$currentHash" != "$configuredHash" ]]; then
                      ${pkgs.coreutils}/bin/printf '%s\n' \
                        "warning: password for user '${name}' will change during this activation." \
                        "warning: oo7 PAM will use the new password on the next login." \
                        "warning: if an oo7 keyring already exists, run before logging out:" \
                        "warning:   oo7-cli change-secret" \
                        "warning: and enter the new account password to re-encrypt the oo7 keyring." >&2
                    fi
                  '') passwordFileUsers
                );
            };
            users.deps = lib.mkAfter [ "oo7PasswordChangeWarning" ];
          };
    };

  flake.modules.homeManager.clj-keyring = { config, ... }: {
    home.persistence.${config.clj.impermanence.persistDir}.directories = [
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];
  };
}

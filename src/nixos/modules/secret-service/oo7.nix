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
{...}: let
  mkOo7Pinned = pkgs: let
    # nixpkgs 0.6.0 lacks the default-alias and content-type fixes required by
    # the secret-management decision. The 0.7.0.beta tag has a PAM bug where
    # the login helper inherits the console login's terminal and can be killed
    # by SIGHUP before oo7-daemon receives the password:
    # https://github.com/linux-credentials/oo7/pull/624
    #
    # This revision includes that fix.
    oo7Rev = "e55a1b10fc16c252811b4c7f7cf3603f743679e0";
    oo7Src = pkgs.fetchFromGitHub {
      owner = "linux-credentials";
      repo = "oo7";
      rev = oo7Rev;
      hash = "sha256-nhkLL9xgSAIAlV+VN8R5S2kaaW326xupSviEighYGN4=";
    };
    oo7CargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = oo7Src;
      name = "oo7-${oo7Rev}";
      hash = "sha256-6jj21lbSv0SM3shReI8meih135I38UqjWGfn04kMSf4=";
    };
    oo7 = pkgs.oo7.overrideAttrs (_old: {
      version = "0.7.0-alpha-${builtins.substring 0 7 oo7Rev}";
      src = oo7Src;
      cargoDeps = oo7CargoDeps;
    });
    oo7Server = pkgs.callPackage "${pkgs.path}/pkgs/by-name/oo/oo7-server/package.nix" {inherit oo7;};
    oo7Portal = pkgs.callPackage "${pkgs.path}/pkgs/by-name/oo/oo7-portal/package.nix" {inherit oo7;};
    # The nixpkgs PAM derivation was written for 0.6.0. oo7 0.7 links PAM
    # directly and expects oo7-daemon-login next to the PAM module, so the
    # pinned PAM build needs linux-pam in buildInputs and the helper from the
    # server package.
    oo7Pam = (pkgs.callPackage "${pkgs.path}/pkgs/by-name/oo/oo7-pam/package.nix" {inherit oo7;}).overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [pkgs.pam];
      postInstall =
        (old.postInstall or "")
        + ''
          install -Dm755 ${oo7Server}/libexec/oo7-daemon-login $out/libexec/oo7-daemon-login
        '';
    });
  in {
    inherit oo7 oo7Server oo7Portal oo7Pam;
  };
in {
  flake.modules.nixos.clj-keyring = {
    config,
    lib,
    pkgs,
    ...
  }: let
    kdeEnabled = config.services.desktopManager.plasma6.enable or false;
  in {
    # Replace the packaged oo7 components so services.oo7 uses the pinned
    # post-beta revision throughout the daemon, PAM module, and portal.
    nixpkgs.overlays = [
      (_final: prev: let
        oo7Pkgs = mkOo7Pinned prev;
      in {
        inherit (oo7Pkgs) oo7;
        oo7-pam = oo7Pkgs.oo7Pam;
        oo7-server = oo7Pkgs.oo7Server;
        oo7-portal = oo7Pkgs.oo7Portal;
      })
    ];

    services.oo7.enable = true;

    # The daemon can start before the graphical session environment has been
    # imported into the user manager. It uses this variable to select the
    # Plasma prompter for manual unlocks.
    # Without this, I experienced `oo7-cli unlock` getting stuck.
    systemd.user.services.oo7-daemon.serviceConfig.Environment = lib.mkIf kdeEnabled ["XDG_CURRENT_DESKTOP=KDE"];

    # Make sure the portal selects oo7 even though oo7-portal.portal declares
    # UseIn=gnome. The daemon itself still provides org.freedesktop.secrets.
    xdg.portal = {
      enable = lib.mkDefault true;
      config.common."org.freedesktop.impl.portal.Secret" = lib.mkForce ["oo7-portal"];
    };

    # KWallet is a second Secret Service provider and must not run alongside
    # oo7. Exclude its packages and PAM hooks when Plasma is enabled.
    environment.plasma6.excludePackages = lib.mkIf kdeEnabled (with pkgs.kdePackages; [
      kwallet
      kwallet-pam
      kwalletmanager
      signon-kwallet-extension
    ]);
    security.pam.services = lib.mkIf kdeEnabled {
      login.kwallet.enable = lib.mkForce false;
      sddm.kwallet.enable = lib.mkForce false;
      kde.kwallet.enable = lib.mkForce false;
    };

    # Changing hashedPasswordFile under users.mutableUsers = false changes the
    # account password without invoking PAM. Warn while the old oo7 session is
    # still unlocked so the user can re-encrypt the keyring before logout.
    system.activationScripts = lib.mkIf (!config.users.mutableUsers && !config.systemd.sysusers.enable && !config.services.userborn.enable) {
      oo7PasswordChangeWarning = {
        supportsDryActivation = true;
        text = let
          passwordFileUsers = lib.filterAttrs (_name: user: user.hashedPasswordFile != null) config.users.users;
        in
          lib.concatStringsSep "\n" (lib.mapAttrsToList (name: user: ''
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
            '')
            passwordFileUsers);
      };
      users.deps = lib.mkAfter ["oo7PasswordChangeWarning"];
    };
  };

  flake.modules.homeManager.clj-keyring = {config, ...}: {
    home.persistence.${config.clj.impermanence.persistDir}.directories = [
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];
  };
}

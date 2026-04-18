# Some unused code that records an attempt to use oo7.
#
# Two issues (from Claude):
# 
# * Alias path lock and unlock
# * Secret content type with charse is not supported text/plain; charset=utf8
{...}: let
  mkOo7Pinned = pkgs: let
    oo7Rev = "317cb39335d10b602a1e01b536bb49cd757f525d";
    oo7AliasUnlockPatch = pkgs.writeText "oo7-alias-unlock.patch" ''
      diff --git a/src/service/mod.rs b/src/service/mod.rs
      index 8a5318b..3db1fe5 100644
      --- a/src/service/modDEFAULT_COLLECTION_ALIAS_PATHs
      +++ b/src/service/mod.rs
      @@ -1107,7 +1107,11 @@ impl Service {
               for object in objects {
                   for (path, collection) in collections.iter() {
                       let collection_locked = collection.is_locked().await;
      -                if *object == *path {
      +                let is_default_alias =
      +                    object.as_str() == DEFAULT_COLLECTION_ALIAS_PATH.as_str()
      +                        && collection.alias().await == oo7::dbus::Service::DEFAULT_COLLECTION;
      +
      +                if *object == *path || is_default_alias {
                           if collection_locked == locked {
                               tracing::debug!(
                                   "Collection: {} is already {}.",
    '';
    oo7Src = pkgs.fetchFromGitHub {
      owner = "linux-credentials";
      repo = "oo7";
      rev = oo7Rev;
      hash = "sha256-HI0h+ou+iWpnNdS7MFxHMDiufwV1hMucr4BFj7qMiO0=";
    };
    oo7Pinned = pkgs.rustPlatform.buildRustPackage {
      pname = "oo7";
      version = "0.6.0-alpha-${builtins.substring 0 7 oo7Rev}";
      src = oo7Src;
      buildAndTestSubdir = "cli";
      cargoHash = "sha256-bjoCJnYLDHYT3c9VcP4bywsTRZOJpRlZurXJfreuOyQ=";
      nativeBuildInputs = [pkgs.pkg-config];
      meta = {
        description = "James Bond went on a new mission as a Secret Service provider";
        homepage = "https://github.com/linux-credentials/oo7";
        changelog = "https://github.com/linux-credentials/oo7/commit/${oo7Rev}";
        license = pkgs.lib.licenses.mit;
        platforms = pkgs.lib.platforms.linux;
        mainProgram = "oo7-cli";
      };
    };
    oo7ServerPinned = (pkgs.callPackage "${pkgs.path}/pkgs/by-name/oo/oo7-server/package.nix" {oo7 = oo7Pinned;}).overrideAttrs (old: {
      patches = (old.patches or []) ++ [oo7AliasUnlockPatch];
      postPatch = (old.postPatch or "") + ''
        substituteInPlace ../client/src/secret.rs \
          --replace-fail 'match s {' 'let media_type = s.split(";").next().map(str::trim).unwrap_or(""); match media_type {' \
          --replace-fail 'e => Err(format!("Invalid content type: {e}")),' '_ => Err(format!("Invalid content type: {s}")),'
      '';
    });
    oo7PortalPinned = pkgs.callPackage "${pkgs.path}/pkgs/by-name/oo/oo7-portal/package.nix" {oo7 = oo7Pinned;};
    oo7PamPinned = pkgs.rustPlatform.buildRustPackage {
      pname = "oo7-pam";
      version = "0.6.0-alpha-${builtins.substring 0 7 oo7Rev}";
      src = oo7Src;
      buildAndTestSubdir = "pam";
      cargoBuildFlags = [
        "-p"
        "oo7-pam"
      ];
      cargoHash = "sha256-bjoCJnYLDHYT3c9VcP4bywsTRZOJpRlZurXJfreuOyQ=";
      nativeBuildInputs = [pkgs.pkg-config];
      installPhase = ''
        runHook preInstall
        so_path="$(find target -type f -name 'libpam_oo7.so' | head -n1)"
        if [ -z "$so_path" ]; then
          echo "libpam_oo7.so not found in build output" >&2
          exit 1
        fi
        install -Dm755 "$so_path" "$out/lib/security/pam_oo7.so"
        runHook postInstall
      '';
      meta = oo7Pinned.meta // {
        description = "${oo7Pinned.meta.description} (PAM module)";
      };
    };
  in {
    oo7 = oo7Pinned;
    oo7Server = oo7ServerPinned;
    oo7Portal = oo7PortalPinned;
    oo7Pam = oo7PamPinned;
  };
in {
  flake.modules.nixos.clj-keyring = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hmUsers = lib.attrByPath ["home-manager" "users"] {} config;
    enabledUsers = lib.attrNames (lib.filterAttrs (_name: hmCfg: lib.attrByPath ["clj" "keyring" "enable"] true hmCfg) hmUsers);
    kdeEnabled = config.services.desktopManager.plasma6.enable or false;
    oo7Pinned = mkOo7Pinned pkgs;
    oo7Pkg = oo7Pinned.oo7;
    oo7ServerPkg = oo7Pinned.oo7Server;
    oo7PortalPkg = oo7Pinned.oo7Portal;
    oo7PamPkg = oo7Pinned.oo7Pam;
    oo7PamModulePath = "${oo7PamPkg}/lib/security/pam_oo7.so";
  in {
    config = lib.mkIf (enabledUsers != []) {
      # oo7 provides org.freedesktop.secrets.
      environment.systemPackages = [
        oo7Pkg
        oo7ServerPkg
        oo7PortalPkg
        oo7PamPkg
      ];
      systemd.packages = [
        oo7ServerPkg
        oo7PortalPkg
      ];

      # Expose the Secret portal backend implementation.
      xdg.portal.extraPortals = [oo7PortalPkg];
      xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = ["oo7-portal"];

      # Disable KDE Wallet integration when KDE is enabled.
      environment.plasma6.excludePackages = lib.mkIf kdeEnabled (with pkgs.kdePackages; [
        kwallet
        kwallet-pam
        kwalletmanager
        signon-kwallet-extension
      ]);
      security.pam.services = lib.mkMerge [
        (lib.mkIf kdeEnabled {
          sddm.kwallet.enable = lib.mkForce false;
          login.kwallet.enable = lib.mkForce false;
          kde.kwallet.enable = lib.mkForce false;
          sddm.rules.auth = {
            unix.control = lib.mkForce "required";
            deny.enable = lib.mkForce false;
          };

          sddm.rules = {
            auth.oo7 = {
              control = "optional";
              modulePath = oo7PamModulePath;
              order = config.security.pam.services.sddm.rules.auth.unix.order + 10;
            };
            session.oo7 = {
              control = "optional";
              modulePath = oo7PamModulePath;
              args = ["auto_start"];
              order = config.security.pam.services.sddm.rules.session.unix.order + 10;
            };
          };
        })
        {
          login.rules.auth = {
            unix.control = lib.mkForce "required";
            deny.enable = lib.mkForce false;
          };
          sshd.rules.auth = {
            unix.control = lib.mkForce "required";
            deny.enable = lib.mkForce false;
          };

          login.rules = {
            auth.oo7 = {
              control = "optional";
              modulePath = oo7PamModulePath;
              order = config.security.pam.services.login.rules.auth.unix.order + 10;
            };
            session.oo7 = {
              control = "optional";
              modulePath = oo7PamModulePath;
              args = ["auto_start"];
              order = config.security.pam.services.login.rules.session.unix.order + 10;
            };
          };

          sshd.rules = {
            auth.oo7 = {
              control = "optional";
              modulePath = oo7PamModulePath;
              order = config.security.pam.services.sshd.rules.auth.unix.order + 10;
            };
            session.oo7 = {
              control = "optional";
              modulePath = oo7PamModulePath;
              args = ["auto_start"];
              order = config.security.pam.services.sshd.rules.session.unix.order + 10;
            };
          };

          passwd.rules.password.oo7 = {
            control = "optional";
            modulePath = oo7PamModulePath;
            args = ["use_authtok"];
            order = config.security.pam.services.passwd.rules.password.unix.order + 10;
          };
        }
      ];
    };
  };

  flake.modules.homeManager.clj-keyring = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.clj.keyring;
    oo7Pinned = mkOo7Pinned pkgs;
    oo7Pkg = oo7Pinned.oo7;
    oo7ServerPkg = oo7Pinned.oo7Server;
    oo7PortalPkg = oo7Pinned.oo7Portal;
    oo7Exec = "${oo7ServerPkg}/libexec/oo7-daemon --replace";
    oo7DataHome = "${config.home.homeDirectory}/.local/share/oo7";
  in {
    options.clj.keyring.enable = lib.mkEnableOption "oo7 keyring backend for org.freedesktop.secrets" // {default = true;};

    config = lib.mkIf cfg.enable {
      home.packages = [
        pkgs.libsecret
        oo7Pkg
        oo7ServerPkg
        oo7PortalPkg
      ];

      xdg.configFile."kwalletrc".text = ''
        [Wallet]
        Enabled=false
        First Use=false
      '';

      systemd.user.services.oo7-daemon = {
        Unit = {
          Description = "Secret service (oo7 implementation)";
        };
        Service = {
          Environment = "XDG_DATA_HOME=${oo7DataHome}";
          ExecStart = lib.mkForce oo7Exec;
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      systemd.user.services."dbus-org.freedesktop.secrets" = {
        Unit = {
          Description = "Secret service (oo7 implementation)";
        };
        Service = {
          Environment = "XDG_DATA_HOME=${oo7DataHome}";
          ExecStart = lib.mkForce oo7Exec;
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
  };
}

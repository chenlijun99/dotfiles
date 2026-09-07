# Codex CLI and nono sandbox (reusable, company-neutral home-manager module)
#
# Thin wrapper over the upstream `programs.codex` module. It only fixes the
# one thing that is broken for codex: home-manager symlinks `config.toml`
# read-only into /nix/store, but codex rewrites that file at runtime
# (trust_level, model/effort selection, notices).
# See https://github.com/nix-community/home-manager/issues/9397 and the
# workaround pattern in https://github.com/holidayworking/core/pull/433.
#
# Approach: disable the generated symlink for config.toml and on activation
# merge the nix-generated (static) settings with any previous *writable* copy
# (codex state) into a plain file. Static settings win; untouched codex state
# (e.g. `[projects.*]` trust, notices) is carried over. Fenced blocks managed
# by tools such as nono are kept byte-for-byte so those tools can update or
# remove their own configuration later.
#
# Codex itself remains configurable through the upstream
# `programs.codex.{settings,plugins,hooks,mcpServers,...}` options. The local
# `clj.programs.codex.nono` options only configure the sandboxed launcher.
{...}: {
  flake.modules.homeManager.clj-codex = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.clj.programs.codex;
    nonoCfg = cfg.nono;
    agentsMdSource = config.lib.clj.linkDotfile "src/nixos/modules/ai/codex/AGENTS.md";
    vimConfigSource = config.lib.clj.linkDotfile "src/vim/";
    cljCodexProfile = pkgs.replaceVars ./clj-codex.jsonc {
      vimConfig = toString vimConfigSource;
    };
    codexMutableConfig = pkgs.writers.writePython3Bin "codex-mutable-config" {
      libraries = [pkgs.python3Packages.tomli-w];
    } (builtins.readFile ./mutable_config.py);
    codexPackage =
      if config.programs.codex.package == null
      then pkgs.codex
      else config.programs.codex.package;
    nonoCodex = pkgs.writeShellApplication {
      name = "nono-codex";
      runtimeInputs = [pkgs.nono];
      text = ''
        set -euo pipefail

        profile=${lib.escapeShellArg nonoCfg.profile}
        if [ -n "''${CODEX_NONO_PROFILE:-}" ]; then
          profile="$CODEX_NONO_PROFILE"
        fi
        if [ "''${1:-}" = "--nono-profile" ]; then
          if [ "$#" -lt 2 ]; then
            echo "nono-codex: --nono-profile requires a profile name or path" >&2
            exit 2
          fi
          profile="$2"
          shift 2
        fi

        # Bootstrap the signed base explicitly. This also supports older nono
        # releases that cannot install it while resolving a local child profile.
        if ! ${lib.getExe pkgs.nono} profile show codex >/dev/null 2>&1; then
          echo "Installing the signed nolabs-ai/codex nono pack..." >&2
          ${lib.getExe pkgs.nono} pull nolabs-ai/codex
        fi

        exec ${lib.getExe pkgs.nono} run \
          --allow-cwd \
          --read-file ${lib.escapeShellArg (toString agentsMdSource)} \
          --profile "$profile" -- \
          ${lib.getExe nonoCfg.commandPackage} \
          --sandbox danger-full-access \
          --ask-for-approval on-request \
          --config allow_login_shell=true \
          --config 'shell_environment_policy.inherit="all"' \
          --config shell_environment_policy.ignore_default_excludes=true \
          "$@"
      '';
    };

    # Same attribute name the upstream module uses for the generated file:
    # relative (`.codex/config.toml`) unless XDG dirs are preferred. Using the
    # absolute path here would create a *second* (undefined) entry whose
    # `source` has no default in home-manager and access would fail.
    configDir =
      if config.home.preferXdgDirectories
      then "${config.xdg.configHome}/codex"
      else ".codex";
    fileKey = "${configDir}/config.toml";
    agentsMdKey = "${configDir}/AGENTS.md";
    configFile =
      if lib.hasPrefix "/" configDir
      then fileKey
      else "${config.home.homeDirectory}/${fileKey}";
    # Only run the writable-config machinery when there is an actual static
    # config to seed; otherwise `config.home.file."${fileKey}".source` (which
    # has no default in home-manager) must not be evaluated.
    hasSettings = (config.programs.codex.settings or {}) != {};
  in {
    options.clj.programs.codex = {
      enable = lib.mkEnableOption "codex CLI" // {default = true;};
      nono = {
        enable = lib.mkEnableOption "the nono-sandboxed Codex launcher" // {default = true;};
        profile = lib.mkOption {
          type = lib.types.str;
          default = "clj-codex";
          description = "Default nono profile used by nono-codex.";
        };
        commandPackage = lib.mkOption {
          type = lib.types.package;
          default = codexPackage;
          defaultText = lib.literalExpression "config.programs.codex.package";
          description = "Package whose main executable nono-codex launches inside nono.";
        };
      };
    };

    config = lib.mkIf cfg.enable {
      # Persist the whole codex home so auth.json, logs, and the writable
      # config.toml (state) survive reboots on impermanence-based systems.
      home.persistence.${config.clj.impermanence.persistDir} = {
        directories = [
          ".codex"
          ".config/nono"
        ];
      };

      home.packages = lib.mkIf nonoCfg.enable [
        pkgs.nono
        nonoCodex
      ];

      programs.codex.enable = true;

      xdg.configFile."nono/profiles/clj-codex.jsonc".source = cljCodexProfile;

      # Ensure writable grants are not skipped by nono on a fresh machine.
      home.file = {
        ".local/share/nvim/undo/.keep".text = "";
        ".local/state/nvim/.keep".text = "";
        ".cache/nvim/.keep".text = "";
      };

      # Shared TUI defaults (machines can override via `lib.mkForce`-style
      # settings, or just set `settings.tui.*` themselves).
      #
      # See
      # https://learn.chatgpt.com/docs/config-file/config-sample
      # for a reference of all config options
      programs.codex.settings = {
        tui = {
          status_line = lib.mkDefault [
            "current-dir"
            "model-with-reasoning"
            "context-remaining"
          ];
          status_line_use_colors = lib.mkDefault true;
        };
        # The nolabs-ai/codex pack installs sandbox-diagnostic hooks, but leaves
        # this Codex feature opt-in to the user.
        features.hooks = lib.mkDefault true;
      };

      # 1. Don't let home-manager symlink config.toml into the store. Keyed
      # exactly like the upstream module so both defs merge on the same entry.
      home.file.${fileKey}.enable = lib.mkIf hasSettings false;

      home.file.${agentsMdKey} = {
        source = agentsMdSource;
      };

      # 2. On activation, merge static settings with the previous writable copy.
      home.activation.codexMutableConfig = lib.mkIf hasSettings (lib.hm.dag.entryAfter [
          "linkGeneration"
        ] ''
          ${lib.getExe codexMutableConfig} \
            --static ${lib.escapeShellArg config.home.file.${fileKey}.source} \
            --output ${lib.escapeShellArg configFile}
        '');
    };
  };
}

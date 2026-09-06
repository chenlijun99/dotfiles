# Codex CLI (reusable, company-neutral home-manager module)
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
# (e.g. `[projects.*]` trust, notices) is carried over.
#
# No new options are defined on purpose: machines configure codex by setting
# the upstream `programs.codex.{settings,plugins,hooks,mcpServers,...}` options
# directly.
{...}: {
  flake.modules.homeManager.clj-codex = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.clj.programs.codex;

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
    };

    config = lib.mkIf cfg.enable {
      # Persist the whole codex home so auth.json, logs, and the writable
      # config.toml (state) survive reboots on impermanence-based systems.
      home.persistence.${config.clj.impermanence.persistDir} = {
        directories = [".codex"];
      };

      programs.codex.enable = true;

      # Shared TUI defaults (machines can override via `lib.mkForce`-style
      # settings, or just set `settings.tui.*` themselves).
      #
      # See
      # https://learn.chatgpt.com/docs/config-file/config-sample
      # for a reference of all config options
      programs.codex.settings.tui = {
        status_line = lib.mkDefault [
          "current-dir"
          "model-with-reasoning"
          "context-remaining"
        ];
        status_line_use_colors = lib.mkDefault true;
      };

      # 1. Don't let home-manager symlink config.toml into the store. Keyed
      # exactly like the upstream module so both defs merge on the same entry.
      home.file.${fileKey}.enable = lib.mkIf hasSettings false;

      home.file.${agentsMdKey} = {
        source = config.lib.clj.linkDotfile "src/nixos/modules/ai/codex/AGENTS.md";
      };

      # 2. On activation, merge static settings with the previous writable copy.
      home.activation.codexMutableConfig = lib.mkIf hasSettings (lib.hm.dag.entryAfter [
          "linkGeneration"
        ] ''
          configFile=${lib.escapeShellArg configFile}
          staticConfig=${lib.escapeShellArg config.home.file.${fileKey}.source}

          # Carry over codex-written entries from the previous writable copy;
          # a symlink left by an older generation has nothing worth keeping.
          existingConfig=/dev/null
          if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
            existingConfig="$configFile"
          fi

          # Merge: previous state first, static settings last (static wins).
          mergedConfig="$(mktemp)"
          ${lib.getExe pkgs.yq-go} -p toml -o toml eval-all \
            '. as $item ireduce ({}; . * $item)' \
            "$existingConfig" "$staticConfig" > "$mergedConfig"
          install -Dm644 "$mergedConfig" "$configFile"
          rm -f "$mergedConfig"
        '');
    };
  };
}

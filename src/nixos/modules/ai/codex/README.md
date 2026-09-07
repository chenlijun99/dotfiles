# Codex

The `clj-codex` Home Manager module installs two entry points:

- `codex` runs Codex directly with its built-in sandbox.
- `nono-codex` runs Codex inside [nono](https://nono.sh/), using nono as the
  kernel-enforced filesystem and network sandbox.

`nono-codex` defaults to the Home Manager-managed `clj-codex` profile, which
extends the signed upstream `codex` profile. It has no company or
credential-manager dependency. The first launch installs the
`nolabs-ai/codex` pack, which provides the upstream profile and nono's Codex
diagnostic plugin.

## Home Manager options

The module enables Codex and nono by default. Its launcher-specific options are:

```nix
clj.programs.codex.nono = {
  enable = true;
  profile = "clj-codex";
  commandPackage = pkgs.codex;
};
```

Configure Codex itself through the upstream `programs.codex` options.

## Launcher behavior

The wrapper passes `--allow-cwd`. Starting `nono-codex` from a directory is
treated as consent to share that directory at the access level declared by the
selected profile. The upstream `codex` profile declares read-write access.
This avoids nono asking the same question on every launch. Be mindful of the
directory from which you start it, especially your home directory.

The wrapper also grants read access only to the resolved global `AGENTS.md`
file. This supports an editable dotfiles setup where `~/.codex/AGENTS.md` is a
symlink outside `~/.codex`. The upstream profile's `nix_runtime` group already
grants read-only access to `/nix/store`.

## Neovim

The `clj-codex` profile supports opening Neovim inside Codex. It grants:

- Read-only access to the resolved Vim configuration, including an editable
  dotfiles checkout.
- Read-only access to `~/.local/share/nvim` for plugins and Tree-sitter
  parsers.
- Read-write access to `~/.local/state/nvim` and `~/.cache/nvim` for ShaDa,
  swap files, view state, and caches.
- Read-write access only to `~/.local/share/nvim/undo` within the otherwise
  read-only data directory.

Keeping the plugin directory read-only prevents a sandboxed session from
persisting executable code that a later unsandboxed Neovim session would load.

Override the selected profile explicitly with either form:

```sh
nono-codex --nono-profile profile-name
nono-codex --nono-profile /trusted/path/profile.jsonc
CODEX_NONO_PROFILE=profile-name nono-codex
```

## Codex sandbox and approvals

The launcher uses:

```text
--sandbox danger-full-access --ask-for-approval on-request
```

The first flag disables Codex's nested OS sandbox. nono remains the actual
filesystem and network boundary. The approval policy remains a separate
user-intent gate for consequential Codex actions and applicable MCP or app tool
calls. This is also nono's recommended Codex invocation.

`--dangerously-bypass-approvals-and-sandbox` would remove both Codex layers. It
does not escape the surrounding nono sandbox, but it removes useful approval
prompts and disables nono's Codex permission-diagnostic hooks. It is therefore
not the default.

The module enables hooks with:

```toml
[features]
hooks = true
```

## Custom profiles

nono accepts JSONC, including line comments, block comments, and trailing
commas. A custom profile can extend the upstream profile:

```jsonc
{
  "extends": "clj-codex",
  "meta": {
    "name": "my-codex",
    "version": "1.0.0",
  },
  "filesystem": {
    // A shared library needed by this project.
    "read": ["$HOME/Repositories/shared-library"],
  },
}
```

User profiles live in `~/.config/nono/profiles/`. The upstream Codex profile
grants that directory read-only access and reserves
`~/.config/nono/profile-drafts/` for writable drafts.

Useful commands:

```sh
nono profile show codex
nono profile show clj-codex
nono profile show my-codex
nono profile diff codex clj-codex
nono profile validate ~/.config/nono/profiles/my-codex.jsonc
nono profile guide
```

## Repository-local profile trust

nono can load a profile by path, but it does not currently document automatic
profile discovery from directory ancestors. Silently adding that behavior is
unsafe because a repository profile grants capabilities before the sandbox
starts. An agent with project write access could modify it for the next
session. Explicit path selection confirms intent but does not establish file
integrity.

A direnv-style design can be sound if approval is bound to the exact file
content and the approved copy or hash is stored outside the writable
repository. nono's trust system can also sign and verify arbitrary files. Any
future ancestor discovery should fail closed unless one of those checks
succeeds.

## Mutable Codex configuration

Codex updates `~/.codex/config.toml` at runtime. The module keeps it as a
writable file and merges declarative Home Manager settings into it during
activation. It preserves nono's fenced plugin blocks byte-for-byte because the
fence comments are ownership metadata used when nono updates or removes its
configuration.

## References

- [nono's Codex setup](https://nono.sh/docs/cli/clients/codex)
- [Profiles and groups](https://nono.sh/docs/cli/features/profiles-groups)
- [Profile authoring](https://nono.sh/docs/cli/features/profile-authoring)
- [Trust and attestations](https://nono.sh/docs/cli/features/trust)
- [OpenAI agent approvals and security](https://learn.chatgpt.com/docs/agent-approvals-security)
- [OpenAI Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)

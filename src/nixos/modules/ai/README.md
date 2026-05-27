# AI Module

This module provides a small set of reusable primitives for running AI tools inside a Podman container while still reusing a host-built `devenv`.

## Primitives

* `packages.devenv-wrapper`: a drop-in `devenv` wrapper. Outside `container-shell` it delegates to the real `devenv`; inside `container-shell` it only customizes `devenv direnvrc` so standard `devenv` projects keep working.
* `packages.container-shell`: starts an interactive shell or runs a command inside a prepared Podman container. It detects the project root, mounts the working tree conservatively, overlays `.devenv`, and keeps container home/runtime state ephemeral.
* `packages.ai-tools`: convenience bundle that exposes both `container-shell` and the wrapped `devenv`.
* `lib.mkContainerShellWrapper`: thin helper for building repo-local wrapper commands on top of `container-shell`.
* `.container-shell.yaml`: optional per-project config for extra mounts.

## Expected Project Shape

Use a normal `devenv` + `direnv` setup:

```bash
export DIRENV_WARN_TIMEOUT=20s
eval "$(devenv direnvrc)"
use devenv
```

The project must already have a host-built `.devenv`, because the container reuses `.devenv/shell-env.sh` instead of evaluating Nix inside the container.

## Examples

Run an interactive shell in the current project:

```bash
nix run .#container-shell
```

Start a named session you can later exec back into from another host tmux pane:

```bash
nix run .#container-shell -- --session-name review-session
```

List running managed sessions:

```bash
nix run .#container-shell -- ls
```

Open another shell in a running session:

```bash
nix run .#container-shell -- exec review-session
```

Select a running session with `fzf` and exec into it:

```bash
nix run .#container-shell -- fzf
```

Run a command directly in the prepared container:

```bash
nix run .#container-shell -- -- bash -lc 'pwd && git status --short'
```

Forward a token and mount an extra config directory:

```bash
nix run .#container-shell -- \
  --write-mode overlay \
  --git-access overlay \
  --pass-env GITHUB_TOKEN \
  --extra-mount /home/alice/.codex:rw \
  -- codex
```

Git access defaults to read-only metadata. Use `--git-access overlay` for disposable in-container Git state or `--git-access rw` to let the container mutate host Git metadata directly.

When Git identity is configured for the launch directory, `container-shell` writes a minimal ephemeral `~/.gitconfig` inside the synthetic container home so `git commit` works without mounting the full host Git config. Repo-local identity overrides global defaults, and wrappers can override everything with `CONTAINER_SHELL_GIT_USER_NAME`, `CONTAINER_SHELL_GIT_USER_EMAIL`, and `CONTAINER_SHELL_GIT_DISABLE_SIGNING`.
The worktree itself defaults to direct writes. Use `--write-mode overlay` to give the selected `--write-scope` a disposable overlay, which is useful for parallel agent sessions.

Declare project-specific mounts in `.container-shell.yaml`:

```yaml
version: 1
mounts:
  - path: /home/alice/.codex
    mode: rw
  - source: /home/alice/.gitconfig
    target: /home/alice/.gitconfig
    mode: ro
```

Build a repo-local wrapper around an AI CLI:

```nix
inputs.dotfiles.lib.mkContainerShellWrapper {
  inherit pkgs;
  name = "container-codex";
  containerShell = inputs.dotfiles.packages.${pkgs.system}.container-shell;
  runtimeInputs = [ myAgentPackage ];
  wrappedProgram = "my-agent";
  containerShellDefaultArgs = ''
    --extra-mount ~/.codex:rw
    --pass-env GITHUB_TOKEN
  '';
}
```

## References

https://www.luiscardoso.dev/blog/sandboxes-for-ai

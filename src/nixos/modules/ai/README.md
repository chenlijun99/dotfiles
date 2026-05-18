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

Run a command directly in the prepared container:

```bash
nix run .#container-shell -- -- bash -lc 'pwd && git status --short'
```

Forward a token and mount an extra config directory:

```bash
nix run .#container-shell -- \
  --pass-env GITHUB_TOKEN \
  --extra-mount /home/alice/.codex:rw \
  -- codex
```

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

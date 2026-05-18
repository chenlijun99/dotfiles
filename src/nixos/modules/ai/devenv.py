from __future__ import annotations

import os
import sys

DIRENVRC = """# shellcheck shell=bash

use_devenv() {
  watch_file ".envrc" "$HOME/.direnvrc" "$HOME/.config/direnv/direnvrc"
  watch_file "devenv.nix" "devenv.lock" "devenv.yaml" "devenv.local.nix" "devenv.local.yaml"
  watch_file ".devenv/shell-env.sh" ".devenv/input-paths.txt"

  if [[ ! -f ".devenv/shell-env.sh" ]]; then
    log_error "container-shell: missing $PWD/.devenv/shell-env.sh"
    log_error "Prime this devenv on the host first by entering it once outside the container."
    exit 1
  fi

  local env_watches=()
  if [[ -f ".devenv/input-paths.txt" ]]; then
    while IFS= read -r file; do
      file=$(printf "$file")
      env_watches+=("$file")
    done < ".devenv/input-paths.txt"
  fi
  if [[ ${#env_watches[@]} -gt 0 ]]; then
    watch_file "${env_watches[@]}"
  fi

  source_env ".devenv/shell-env.sh"
}
"""


class WrappedDevenvError(RuntimeError):
    """Raised when the wrapped devenv configuration is invalid."""


def required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise WrappedDevenvError(f"missing required environment variable {name}")
    return value


def should_emit_direnvrc(args: list[str]) -> bool:
    return bool(os.environ.get("CONTAINER_SHELL")) and bool(args) and args[0] == "direnvrc"


def run(argv: list[str]) -> int:
    if should_emit_direnvrc(argv):
        sys.stdout.write(DIRENVRC)
        return 0

    real_devenv = required_env("CONTAINER_SHELL_REAL_DEVENV_BIN")
    os.execv(real_devenv, [real_devenv, *argv])


def main(argv: list[str] | None = None) -> int:
    try:
        return run(sys.argv[1:] if argv is None else argv)
    except WrappedDevenvError as exc:
        print(f"devenv-wrapper: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

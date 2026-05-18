from __future__ import annotations

import json
import os
import shlex
import subprocess
import sys
from pathlib import Path


class WrapperError(RuntimeError):
    """Raised when wrapper configuration or arguments are invalid."""


def load_config(path: str) -> dict[str, object]:
    try:
        with Path(path).open(encoding="utf-8") as handle:
            config = json.load(handle)
    except FileNotFoundError as exc:
        raise WrapperError(f"wrapper config does not exist: {path}") from exc
    except OSError as exc:
        raise WrapperError(f"failed to read wrapper config {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise WrapperError(f"wrapper config is not valid JSON: {path}") from exc

    if not isinstance(config, dict):
        raise WrapperError("wrapper config must be a JSON object")

    return config


def config_str(config: dict[str, object], key: str, *, allow_empty: bool = False) -> str:
    value = config.get(key)
    if not isinstance(value, str) or (not allow_empty and not value):
        requirement = "a string" if allow_empty else "a non-empty string"
        raise WrapperError(f"wrapper config {key!r} must be {requirement}")
    return value


def required_str_list(config: dict[str, object], key: str) -> list[str]:
    value = config.get(key)
    if not isinstance(value, list) or any(not isinstance(item, str) for item in value):
        raise WrapperError(f"wrapper config {key!r} must be a list of strings")
    return value


def expand_token(token: str) -> str:
    return os.path.expanduser(os.path.expandvars(token))


def parse_default_args(raw_args: str) -> list[str]:
    if not raw_args.strip():
        return []
    try:
        return [expand_token(token) for token in shlex.split(raw_args, posix=True)]
    except ValueError as exc:
        raise WrapperError(f"containerShellDefaultArgs is not valid shell syntax: {exc}") from exc


def run_setup(config: dict[str, object]) -> None:
    script = config.get("wrapperSetup", "")
    if not isinstance(script, str):
        raise WrapperError("wrapper config 'wrapperSetup' must be a string")
    if not script.strip():
        return

    bash = config_str(config, "bash")
    try:
        completed = subprocess.run([bash, "-euo", "pipefail", "-c", script], check=False)
    except OSError as exc:
        raise WrapperError(f"failed to execute wrapper setup with {bash}: {exc}") from exc
    if completed.returncode != 0:
        raise SystemExit(completed.returncode)


def consume_wrapper_args(
    argv: list[str],
    *,
    passthrough_options: set[str],
    debug_flag: str,
) -> tuple[list[str], list[str]]:
    container_args: list[str] = []
    index = 0

    while index < len(argv):
        arg = argv[index]
        if arg in passthrough_options:
            if index + 1 >= len(argv):
                raise WrapperError(f"missing value for {arg}")
            container_args.extend((arg, argv[index + 1]))
            index += 2
            continue
        if arg == debug_flag:
            container_args.append("--debug")
            index += 1
            continue
        if arg == "--":
            index += 1
            break
        break

    return container_args, argv[index:]


def build_command(config: dict[str, object], argv: list[str]) -> list[str]:
    config_str(config, "name")
    passthrough_options = set(required_str_list(config, "passthroughContainerOptions"))
    debug_flag = config_str(config, "debugContainerFlag")

    container_args = parse_default_args(config_str(config, "containerShellDefaultArgs", allow_empty=True))
    extra_container_args, wrapped_program_argv = consume_wrapper_args(
        argv,
        passthrough_options=passthrough_options,
        debug_flag=debug_flag,
    )

    return [
        config_str(config, "containerShell"),
        *container_args,
        *extra_container_args,
        "--",
        config_str(config, "wrappedProgram"),
        *required_str_list(config, "wrappedProgramArgs"),
        *wrapped_program_argv,
    ]


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        raise WrapperError("usage: container-shell-wrapper.py CONFIG_PATH [args...]")

    config = load_config(argv[1])
    run_setup(config)
    command = build_command(config, argv[2:])
    try:
        os.execv(command[0], command)
    except OSError as exc:
        raise WrapperError(f"failed to exec {command[0]}: {exc}") from exc


if __name__ == "__main__":
    wrapper_name = "container-shell-wrapper"
    try:
        if len(sys.argv) >= 2:
            wrapper_name = Path(sys.argv[1]).stem
            try:
                wrapper_name = config_str(load_config(sys.argv[1]), "name")
            except (WrapperError, OSError, SystemExit):
                pass
        raise SystemExit(main(sys.argv))
    except WrapperError as exc:
        print(f"{wrapper_name}: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc

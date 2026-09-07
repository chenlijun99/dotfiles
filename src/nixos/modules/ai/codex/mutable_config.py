"""Merge a writable Codex config while preserving nono's owned block."""

from __future__ import annotations

import argparse
import os
import re
import tempfile
from pathlib import Path
from typing import Any

import tomli_w
import tomllib

BEGIN_MARKER = "# >>> nono:nolabs-ai-codex >>>"
END_MARKER = "# <<< nono:nolabs-ai-codex <<<"


class ConfigError(RuntimeError):
    """Raised when merging would risk corrupting the configuration."""


def extract_managed_block(text: str) -> tuple[str, str | None]:
    """Return text outside the nono fence and the exact fenced substring."""
    begin_pattern = rf"(?m)^{re.escape(BEGIN_MARKER)}\r?$"
    begin_matches = list(re.finditer(begin_pattern, text))
    end_matches = list(re.finditer(rf"(?m)^{re.escape(END_MARKER)}\r?$", text))

    if not begin_matches and not end_matches:
        return text, None
    if len(begin_matches) != 1 or len(end_matches) != 1:
        raise ConfigError("expected exactly one complete nono-managed block")

    begin = begin_matches[0]
    end = end_matches[0]
    if end.start() < begin.end():
        raise ConfigError("nono-managed block ends before it begins")

    begin_index = begin.start()
    end_index = end.end()
    block = text[begin_index:end_index]
    unmanaged = text[:begin_index] + text[end_index:]
    return unmanaged, block


def parse_toml(text: str, source: str) -> dict[str, Any]:
    if not text.strip():
        return {}
    try:
        return tomllib.loads(text)
    except tomllib.TOMLDecodeError as error:
        raise ConfigError(f"cannot parse {source}: {error}") from error


def deep_merge(
    base: dict[str, Any],
    override: dict[str, Any],
) -> dict[str, Any]:
    """Recursively merge dictionaries, with override values winning."""
    result = dict(base)
    for key, value in override.items():
        current = result.get(key)
        if isinstance(current, dict) and isinstance(value, dict):
            result[key] = deep_merge(current, value)
        else:
            result[key] = value
    return result


def is_table_value(value: Any) -> bool:
    """Return whether TOML must serialize a top-level value as a table."""
    if isinstance(value, dict):
        return True
    if not isinstance(value, list):
        return False
    return any(isinstance(item, dict) for item in value)


def partition_settings(
    settings: dict[str, Any],
) -> tuple[dict[str, Any], dict[str, Any]]:
    roots: dict[str, Any] = {}
    tables: dict[str, Any] = {}
    for key, value in settings.items():
        target = tables if is_table_value(value) else roots
        target[key] = value
    return roots, tables


def render_config(settings: dict[str, Any], managed_block: str | None) -> str:
    if managed_block is None:
        return tomli_w.dumps(settings)

    roots, tables = partition_settings(settings)
    parts = [
        part
        for part in (
            tomli_w.dumps(roots).rstrip("\n"),
            managed_block,
            tomli_w.dumps(tables).rstrip("\n"),
        )
        if part
    ]
    rendered = "\n\n".join(parts) + "\n"

    # The block may define keys that collide with declarative settings. There
    # is no valid byte-preserving merge in that case, so fail before writing.
    parse_toml(rendered, "merged config")
    return rendered


def merge_config(existing: str, static: str) -> str:
    unmanaged, managed_block = extract_managed_block(existing)
    existing_settings = parse_toml(unmanaged, "existing config")
    static_settings = parse_toml(static, "static config")
    merged = deep_merge(existing_settings, static_settings)
    return render_config(merged, managed_block)


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent,
        prefix=f".{path.name}.",
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(content.encode("utf-8"))
            stream.flush()
            os.fsync(stream.fileno())
        temporary.chmod(0o644)
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--static", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    arguments = parser.parse_args()

    static = arguments.static.read_bytes().decode("utf-8")
    existing = ""
    if arguments.output.is_file() and not arguments.output.is_symlink():
        existing = arguments.output.read_bytes().decode("utf-8")

    try:
        merged = merge_config(existing, static)
    except ConfigError as error:
        parser.error(str(error))
    atomic_write(arguments.output, merged)


if __name__ == "__main__":
    main()

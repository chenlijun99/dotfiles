"""JSON CLI for viewer-driven review workspaces."""
from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from pathlib import Path
from typing import Any

from .core import Error, MissingSession, execute


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(prog="review-session", description=__doc__)
    root.add_argument("--session", required=True, help="explicit disposable session directory")
    root.add_argument("--role", choices=("human", "agent"), default="human")
    commands = root.add_subparsers(dest="operation", required=True)
    target = ["repo", "old", "new", "path", "old-path", "new-path", "view-file", "expected-fingerprint"]
    options = {
        "init": ["repo"], "load": [], "view": target, "status": target,
        "mark": [*target, "value"], "create": [*target, "scope", "side", "start", "end", "body"],
        "threads": target, "history": target, "queue": [], "coverage": ["target", "body"],
        "show": ["thread"], "context": ["thread", "fingerprint"], "source": ["thread", "fingerprint", "side"], "reply": ["thread", "body", "ack"],
        "edit": ["thread", "message", "revision", "body"], "share": ["thread", "value"],
        "resolve": ["thread", "value"], "draft": ["thread", "message", "revision"],
        "reanchor": [*target, "thread", "scope", "side", "start", "end"],
        "preview": ["thread", "destination", "revision", "summary", "expected-preview"], "publish": ["thread", "destination", "revision", "summary", "expected-preview"],
    }
    for command, flags in options.items():
        sub = commands.add_parser(command)
        sub.add_argument("--request-file", help="JSON request object, or - for stdin (programmatic interface)")
        for flag in flags:
            kwargs: dict[str, Any] = {}
            if flag in ("start", "end"):
                kwargs["type"] = int
            if flag == "ack":
                kwargs.update(action="append")
            if flag == "summary":
                kwargs.update(action="store_true", default=None)
            sub.add_argument("--" + flag, **kwargs)
        if "body" in flags:
            sub.add_argument("--body-file", help="UTF-8 Markdown file, or - for stdin")
    return root


def read_file(filename: str) -> str:
    return sys.stdin.read() if filename == "-" else Path(filename).read_text(encoding="utf-8")


def main() -> int:
    parsed = vars(parser().parse_args())
    session, operation = parsed.pop("session"), parsed.pop("operation")
    args = {k: v for k, v in parsed.items() if v is not None}
    try:
        if "request_file" in args:
            payload = json.loads(read_file(args.pop("request_file")))
            if not isinstance(payload, dict):
                raise Error("request must be a JSON object")
            args.update(payload)
        if "body_file" in args:
            args["body"] = read_file(args.pop("body_file"))
        if "view_file" in args:
            args["view"] = json.loads(read_file(args.pop("view_file")))
        result = execute(session, operation, args)
        print(json.dumps(result, ensure_ascii=True))
        return 0
    except (Error, OSError, sqlite3.Error, ValueError, KeyError, TypeError) as error:
        result = {"error": str(error)}
        if isinstance(error, MissingSession):
            result["code"] = "missing_session"
        print(json.dumps(result), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

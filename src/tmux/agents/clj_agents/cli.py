"""clj_agents: hook-free coding-agent overview for tmux.

    clj_agents scan [--format tsv|json]   one row per coding-agent pane
    clj_agents popup                     the picker, bound to prefix + Space
"""

from __future__ import annotations

import argparse

from . import __version__, popup, scan


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="clj_agents", description=__doc__.splitlines()[0])
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    subcommands = parser.add_subparsers(dest="command", required=True)

    scan_cmd = subcommands.add_parser("scan", help="list coding-agent panes and their state")
    scan_cmd.add_argument(
        "--format", choices=("tsv", "json"), default="tsv", help="output format (default: tsv)"
    )
    scan_cmd.add_argument("--rules", type=__import__("pathlib").Path, default=scan.RULES_DIR)
    scan_cmd.set_defaults(run=scan.run)

    popup_cmd = subcommands.add_parser("popup", help="the fzf picker (tmux display-popup target)")
    popup_cmd.set_defaults(run=popup.run)

    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    return args.run(args)


if __name__ == "__main__":
    raise SystemExit(main())

"""tmux popup: every coding agent on this server, with a live pane preview.

fzf renders the list; the preview is the real pane. On every focus event the
client is switched to that agent's pane, so the screen around the popup is the
agent's live screen rather than a text capture (the trick tmux-fzf uses).

Opening the popup does not move you. fzf always has a current item, so when the
pane you are on is an agent it preselects that row, and when it is not it
preselects a placeholder row that stands for "nothing": the client stays put,
and the first cursor move previews the first agent. Closing with `esc` or
`ctrl-c` puts the client back on the pane it started on, previous session
included.

Bound in tmux.conf to `clj_agents popup`, run inside `tmux display-popup`.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from . import detect, scan

DELIM = "\t"
US = "\x1f"
FZF_COLORS = (
    "--color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f,"
    "info:#83a598,prompt:#b8bb26,pointer:#fb4934,marker:#b8bb26,spinner:#fabd2f,"
    "header:#928374,border:#665c54"
)
# Only used when no client can be identified, so no live preview is possible.
FALLBACK_PREVIEW = "--preview=tmux capture-pane -p -t {1}"
# fzf cannot start with no current item, so a line that is not a row stands in
# for "nothing selected". It carries the pane the popup was opened from, so
# previewing it means previewing where you came from, exactly like every other
# row previews the agent it names.
PLACEHOLDER = "\033[90m\u00b7\033[0m"


@dataclass(frozen=True)
class ClientRef:
    """Where the client was before the live preview started moving it."""

    tty: str
    session: str
    window_index: str
    pane_id: str
    last_session: str


def tmux_out(*args: str) -> str:
    try:
        proc = subprocess.run(["tmux", *args], capture_output=True, text=True)
    except FileNotFoundError:
        return ""
    return proc.stdout if proc.returncode == 0 else ""


def tmux(*args: str) -> None:
    # Output is dropped: a pane can disappear between the scan and the action,
    # and a stray tmux error on the popup's last line is just noise.
    subprocess.run(
        ["tmux", *args], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


def apply(plan: list[list[str]]) -> None:
    for args in plan:
        tmux(*args)


def client_ref() -> ClientRef:
    """Where the popup was opened from: the client, and the pane it was on.

    tmux resolves `#{client_*}` inside a popup against whichever client was
    active most recently rather than the client that owns the popup, so the
    binding passes the values in the environment, captured at keypress time.
    The formats remain as a fallback for a hand-run `popup.py`, where only a
    single attached client is resolved correctly.
    """
    env = os.environ
    if env.get("AGENTS_CLIENT"):
        return ClientRef(
            env["AGENTS_CLIENT"],
            env.get("AGENTS_SESSION", ""),
            env.get("AGENTS_WINDOW", ""),
            env.get("AGENTS_PANE", ""),
            env.get("AGENTS_PREV_SESSION", ""),
        )
    raw = tmux_out(
        "display-message",
        "-p",
        US.join(
            (
                "#{client_tty}",
                "#{client_session}",
                "#{window_index}",
                "#{pane_id}",
                "#{client_last_session}",
            )
        ),
    ).rstrip("\n")
    parts = raw.split(US)
    if len(parts) != 5:
        return ClientRef("", "", "", "", "")
    return ClientRef(*parts)


def client_now() -> tuple[str, str]:
    """Current session and previous session of this popup's client."""
    raw = tmux_out(
        "display-message", "-p", US.join(("#{client_session}", "#{client_last_session}"))
    ).rstrip("\n")
    parts = raw.split(US)
    if len(parts) != 2:
        return "", ""
    return parts[0], parts[1]


def switch_plan(session: str, window_index: str, pane_id: str, tty: str) -> list[list[str]]:
    """Move a client onto a pane, without disturbing any other client."""
    return [
        ["select-pane", "-t", pane_id],
        ["switch-client", "-c", tty, "-t", f"{session}:{window_index}"],
    ]


def restore(orig: ClientRef, run=None, query=None) -> None:
    """Put the client back on the pane the popup was opened from.

    The window and pane steps always run: moving between windows of one session
    leaves both session fields untouched, so they cannot be derived from them.

    The session steps replay the history tmux recorded, so `prefix ;` still
    points where it did. The client's session is re-read between them because
    the first switch changes what the second has to do; tmux-fzf re-reads for
    the same reason. Getting this wrong showed up as `ctrl-x` on the
    placeholder leaving the client in the previous session.
    """
    if not orig.tty:
        return
    run = apply if run is None else run
    query = client_now if query is None else query
    session, _previous = query()
    if orig.last_session and session != orig.last_session:
        run([["switch-client", "-c", orig.tty, "-t", orig.last_session]])
        session, _previous = query()
    if session != orig.session:
        run([["switch-client", "-c", orig.tty, "-t", orig.session]])
    if orig.window_index:
        run([["select-window", "-t", f"{orig.session}:{orig.window_index}"]])
    if orig.pane_id:
        run([["select-pane", "-t", orig.pane_id]])


def fzf_args(tty: str, start_index: int) -> list[str]:
    args = [
        "fzf",
        "--ansi",
        "--no-sort",
        "--sync",
        "--reverse",
        "--height=100%",
        "--border=rounded",
        "--info=inline",
        "--prompt=agents> ",
        "--pointer=>",
        "--header=esc back   enter jump   ctrl-x kill   type to filter",
        f"--delimiter={DELIM}",
        "--with-nth=4..",
        # fzf applies --nth to the line --with-nth produced, so the displayed
        # columns are 1.. here, not 4... Asking for 4.. searched only the age
        # and the session name.
        "--nth=1..",
        "--expect=ctrl-x",
        FZF_COLORS,
    ]
    if tty:
        # One tmux call per focus event: select that pane, then move this client
        # there. `\;` is tmux's own command separator, so no extra process.
        focus = f"tmux select-pane -t {{1}} \\; switch-client -c {tty} -t {{2}}:{{3}}"
        args.insert(-1, f"--bind=focus:execute-silent({focus})")
        if start_index > 1:
            args.insert(-1, f"--bind=start:pos({start_index})")
    else:
        args.insert(-1, FALLBACK_PREVIEW)
        args.insert(-1, "--preview-window=right:50%")
    return args


# What the popup's columns have to lose before fzf will show a line in full:
# fzf's own border takes 2, it reserves a column for the scrollbar, and its
# truncation marker ("..") takes 2 more when a line runs past the edge.
LIST_SLACK = 6


def list_width() -> int:
    """Columns of text the list can show, so the age ends at its right edge."""
    try:
        columns = os.get_terminal_size(sys.stdout.fileno()).columns
    except (OSError, ValueError):
        columns = shutil.get_terminal_size((80, 24)).columns
    return max(24, columns - LIST_SLACK)


def placeholder_row(orig: ClientRef) -> str:
    """The line that stands for "nothing selected", in the fzf row shape.

    It targets the pane the popup was opened from, so the preview follows the
    cursor back to that pane when you return to it.
    """
    return DELIM.join(
        [orig.pane_id, orig.session, orig.window_index, f"  {PLACEHOLDER}"]
    )


def kill(row: scan.Row) -> None:
    tmux("kill-pane", "-t", row.pane_id)


def confirm(row: scan.Row) -> bool:
    where = f"{row.session}:{row.window_index} ({row.agent}, {row.cwd})"
    print(f"kill pane {where}? [y/N] ", end="", flush=True)
    try:
        answer = sys.stdin.readline()
    except KeyboardInterrupt:
        return False
    return answer.strip().lower() in ("y", "yes")


def pick(
    rows: list[scan.Row], orig: ClientRef, start_index: int, placeholder: bool
) -> tuple[str, scan.Row | None]:
    listing = "\n".join(scan.fzf_rows(rows, list_width()))
    if placeholder:
        listing = placeholder_row(orig) + "\n" + listing
    proc = subprocess.run(
        fzf_args(orig.tty, start_index), input=listing, text=True, capture_output=True
    )
    if proc.returncode not in (0, 1, 130):
        return "", None
    lines = proc.stdout.splitlines()
    key = lines[0] if lines else ""
    if len(lines) < 2 or not lines[1]:
        return key, None
    pane_id = lines[1].split(DELIM)[0]
    return key, next((r for r in rows if r.pane_id == pane_id), None)


def run(args=None) -> int:
    """`clj_agents popup`: the picker, run inside a tmux popup."""
    ruleset = detect.RuleSet.load(scan.RULES_DIR)
    orig = client_ref()
    while True:
        rows = scan.scan(ruleset)
        if not rows:
            tmux("display-message", "no coding agents running in this tmux server")
            return 0
        # Row 1 based position of the pane the popup was opened from.
        index = next((i for i, r in enumerate(rows, 1) if r.pane_id == orig.pane_id), None)
        key, row = pick(
            rows,
            orig,
            index or 1,
            # Nothing selected: the pane you are on is not an agent, so the
            # placeholder previews that pane.
            placeholder=bool(orig.tty) and index is None,
        )
        if row is None:
            restore(orig)
            return 0
        if key == "ctrl-x":
            if confirm(row):
                kill(row)
            continue
        if orig.tty:
            apply(switch_plan(row.session, row.window_index, row.pane_id, orig.tty))
        return 0


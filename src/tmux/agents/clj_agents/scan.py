"""Scan every tmux pane on this server for coding agents and their state.

Hook-free: detection uses the pane title and the pane screen only (see
detect.py and rules/). One `tmux list-panes` call finds the candidates, then
`capture-pane` runs only for panes whose title alone did not settle the state,
in parallel.
"""

from __future__ import annotations

import os
import subprocess
import threading
import time
from dataclasses import dataclass
from pathlib import Path

from . import detect

RULES_DIR = Path(__file__).resolve().parent / "rules"
SEP = "\x1f"  # ASCII unit separator: not valid in any tmux format output
SCREEN_HISTORY = detect.SCREEN_TAIL_LINES
MAX_WORKERS = 12

FIELDS = (
    "pane_id",
    "session_name",
    "window_index",
    "window_name",
    "pane_pid",
    "pane_current_command",
    "pane_title",
    "pane_current_path",
    "window_activity",
)
FMT = SEP.join("#{%s}" % f for f in FIELDS)

COLORS = {
    detect.WAITING: "\033[1;33m",
    detect.IDLE: "\033[32m",
    detect.WORKING: "\033[35m",
}
UNKNOWN_COLOR = "\033[90m"
RESET = "\033[0m"


def tmux(*args: str) -> str | None:
    try:
        proc = subprocess.run(["tmux", *args], capture_output=True, text=True)
    except FileNotFoundError:
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout


def _read(path: str) -> str:
    try:
        return Path(path).read_text(errors="replace")
    except OSError:
        return ""


def _listdir(path: str) -> list[str]:
    try:
        return os.listdir(path)
    except OSError:
        return []


def proc_comm(pid: int) -> str:
    return _read(f"/proc/{pid}/comm").strip()


def proc_argv(pid: int) -> list[str]:
    try:
        raw = Path(f"/proc/{pid}/cmdline").read_bytes()
    except OSError:
        return []
    return [arg for arg in raw.decode("utf-8", "replace").split("\0") if arg]


def proc_children(pid: int) -> list[int]:
    kids: list[int] = []
    for task in _listdir(f"/proc/{pid}/task"):
        for raw in _read(f"/proc/{pid}/task/{task}/children").split():
            try:
                kids.append(int(raw))
            except ValueError:
                pass
    return kids


def descendants(pid: int, limit: int = 64) -> list[int]:
    out: list[int] = []
    stack = [pid]
    seen = {pid}
    while stack and len(out) < limit:
        for kid in proc_children(stack.pop()):
            if kid in seen:
                continue
            seen.add(kid)
            out.append(kid)
            stack.append(kid)
    return out


@dataclass
class Pane:
    pane_id: str
    session: str
    window_index: str
    window_name: str
    pid: int
    comm: str
    title: str
    cwd: str
    activity: int


@dataclass
class Row:
    pane_id: str
    session: str
    window_index: str
    window_name: str
    agent: str
    state: str
    reason: str
    cwd: str
    age: int | None
    title: str
    subject: str


def list_panes() -> list[Pane]:
    out = tmux("list-panes", "-a", "-F", FMT)
    if not out:
        return []
    panes = []
    for line in out.splitlines():
        parts = line.split(SEP)
        if len(parts) != len(FIELDS):
            continue
        pane_id, session, widx, wname, pid, comm, title, cwd, activity = parts
        try:
            pid_i = int(pid)
        except ValueError:
            pid_i = 0
        try:
            activity_i = int(activity or 0)
        except ValueError:
            activity_i = 0
        panes.append(Pane(pane_id, session, widx, wname, pid_i, comm, title, cwd, activity_i))
    return panes


def resolve_agent(ruleset: detect.RuleSet, pane: Pane) -> detect.AgentRules | None:
    """Identify the agent in a pane, probing the process tree for host bins."""
    rule = ruleset.match_bin(pane.comm)
    if rule is not None:
        return rule
    if pane.comm not in detect.HOST_BINS or not pane.pid:
        return None
    tree = [pane.pid, *descendants(pane.pid)]
    for pid in tree:
        rule = ruleset.match_bin(proc_comm(pid))
        if rule is not None:
            return rule
    for pid in tree:
        rule = ruleset.match_argv(proc_argv(pid))
        if rule is not None:
            return rule
    return None


def capture_all(pairs: list[tuple[Pane, detect.AgentRules]]) -> dict[str, str]:
    """Capture many panes at once, a bounded number of subprocesses in flight.

    capture-pane is the only expensive part of a scan, and it is IO bound, so
    threads shard the work while the interpreter itself stays single threaded.
    """
    screens: dict[str, str] = {}
    lock = threading.Lock()
    buckets = [pairs[i::MAX_WORKERS] for i in range(MAX_WORKERS)]

    def run(bucket: list[tuple[Pane, detect.AgentRules]]) -> None:
        local = {pane.pane_id: capture(pane.pane_id) for pane, _ in bucket}
        with lock:
            screens.update(local)

    threads = [threading.Thread(target=run, args=(bucket,)) for bucket in buckets if bucket]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    return screens


def capture(pane_id: str) -> str:
    return tmux("capture-pane", "-p", "-t", pane_id, "-S", f"-{SCREEN_HISTORY}") or ""


def age_str(age: int | None) -> str:
    if age is None or age < 0:
        return "-"
    if age < 60:
        return f"{age}s"
    if age < 3600:
        return f"{age // 60}m"
    if age < 86400:
        return f"{age // 3600}h"
    return f"{age // 86400}d"


def scan(ruleset: detect.RuleSet) -> list[Row]:
    """Return one row per pane that is running a registered coding agent."""
    panes = list_panes()
    now = int(time.time())

    matched: list[tuple[Pane, detect.AgentRules]] = []
    for pane in panes:
        rule = resolve_agent(ruleset, pane)
        if rule is not None:
            matched.append((pane, rule))

    # Title-only hits (Codex spinning while it works) need no capture call.
    settled: dict[str, tuple[str, str]] = {}
    needs_screen: list[tuple[Pane, detect.AgentRules]] = []
    for pane, rule in matched:
        fast = detect.resolve_title_only(rule, pane.title)
        if fast is None:
            needs_screen.append((pane, rule))
        else:
            settled[pane.pane_id] = fast

    if needs_screen:
        screens = capture_all(needs_screen)
        for pane, rule in needs_screen:
            settled[pane.pane_id] = detect.resolve_state(
                rule, pane.title, lambda sid=pane.pane_id: screens.get(sid, "")
            )

    rows = []
    for pane, rule in matched:
        state, reason = settled[pane.pane_id]
        age = now - pane.activity if pane.activity else None
        rows.append(
            Row(
                pane.pane_id,
                pane.session,
                pane.window_index,
                pane.window_name,
                rule.name,
                state,
                reason,
                pane.cwd,
                age,
                pane.title,
                detect.subject(rule, pane.title, pane.cwd),
            )
        )
    rows.sort(
        key=lambda r: (
            detect.STATE_RANK.get(r.state, 2),
            r.session,
            int(r.window_index or 0),
            r.pane_id,
        )
    )
    return rows


def tsv_rows(rows: list[Row]) -> list[str]:
    out = []
    for r in rows:
        out.append(
            "\t".join(
                [
                    r.pane_id,
                    r.session,
                    r.window_index,
                    r.window_name,
                    r.agent,
                    r.state,
                    r.reason,
                    r.cwd,
                    "-" if r.age is None else str(r.age),
                    r.title,
                    r.subject,
                ]
            )
        )
    return out


AGE_WIDTH = 4          # " 12s", right aligned against the line's right edge
STATE_WIDTH = 7        # waiting / working / idle
LOC_MAX = 24           # session:window, the window index is kept when cut
AGENT_MAX = 9          # opencode


def _fit(text: str, width: int, keep: str = "") -> str:
    """Truncate to `width`, keeping `keep` (a suffix such as ":2") visible."""
    if len(text) <= width:
        return text
    room = max(1, width - len(keep) - 1)
    return text[:room] + "\u2026" + keep


def fzf_line(r: Row, width: int, loc_width: int, agent_width: int) -> str:
    """One display line: columns padded to a common width, age against the right.

    The column widths come from the rows being shown, so a long session name
    widens the column for every row instead of pushing the later columns out of
    line. The age is last because it is the column worth losing, but it is also
    the column worth lining up, so the line is padded to the width the popup
    gives the list and the age sits against that right edge. When a row runs out
    of room the session name gives way first, never the age.
    """
    age = f"{age_str(r.age):>{AGE_WIDTH}}"
    loc = _fit(f"{r.session}:{r.window_index}", loc_width, keep=f":{r.window_index}")
    agent = _fit(r.agent, agent_width)
    head = f"{r.state:<{STATE_WIDTH}} {loc:<{loc_width}} {agent:<{agent_width}} "
    room = max(7, width - AGE_WIDTH)
    body = (head + r.subject)[:room].ljust(room)
    color = COLORS.get(r.state, UNKNOWN_COLOR)
    # The state is the only coloured part, so it is spliced in after padding.
    return f"{color}{body[:STATE_WIDTH]}{RESET}{body[STATE_WIDTH:]}{age}"


def fzf_rows(rows: list[Row], width: int = 100) -> list[str]:
    """Rows for fzf.

    Fields 1 to 3 are the machine readable target (pane id, session, window
    index) that the focus binding interpolates. Field 4 is the whole display
    line, so `--with-nth=4` shows exactly it and `--nth=1` searches exactly it
    (fzf numbers fields after `--with-nth`), leaving the target unsearchable.
    """
    loc_width = min(
        LOC_MAX, max((len(f"{r.session}:{r.window_index}") for r in rows), default=0)
    )
    agent_width = min(AGENT_MAX, max((len(r.agent) for r in rows), default=0))
    return [
        "\t".join(
            [
                r.pane_id,
                r.session,
                r.window_index,
                fzf_line(r, width, loc_width, agent_width),
            ]
        )
        for r in rows
    ]


def json_rows(rows: list[Row]) -> str:
    import json

    return json.dumps([r.__dict__ for r in rows], indent=2)


def run(args) -> int:
    """`clj_agents scan`: print one row per coding-agent pane."""
    ruleset = detect.RuleSet.load(args.rules)
    rows = scan(ruleset)
    if args.format == "json":
        print(json_rows(rows))
        return 0
    lines = tsv_rows(rows)
    if lines:
        print("\n".join(lines))
    return 0

"""Hook-free coding-agent state detection.

Detection reads only what tmux already knows: the pane title and the last
lines of the pane screen. Nothing is installed into the agents and nothing
runs inside them.

The rules in rules/*.conf are vendored verbatim (MIT) from snirt/agenmux,
which in turn ports them from herdr. See rules/LICENSE.agenmux. The conf
format is shell syntax (KEY=value with quoted values, # comments); it is
parsed here without executing anything.
"""

from __future__ import annotations

import re
import socket
from dataclasses import dataclass
from pathlib import Path

WORKING = "working"
WAITING = "waiting"
IDLE = "idle"

# Sort rank for the picker: things that want you first.
STATE_RANK = {WAITING: 0, IDLE: 1, WORKING: 3}

# Check ids usable in CHECK_ORDER:
#   bt  blocked_title    bs  blocked_screen
#   wt  working_title    ws  working_screen
#   is  idle_screen
TITLE_CHECKS = ("bt", "wt")
SCREEN_CHECKS = ("bs", "ws", "is")
DEFAULT_ORDER = ("bt", "wt", "bs", "ws")

# Processes too generic to identify an agent on their own. A pane running one
# of these is probed via its process tree and command line before it counts.
HOST_BINS = ("node", "npm")

# How many trailing screen lines the rules are matched against, as in agenmux.
SCREEN_TAIL_LINES = 20

_ESCAPES = {'"': '"', "\\": "\\", "`": "`", "$": "$"}


def _value(text: str, i: int) -> tuple[str, int]:
    """Read one conf value starting at text[i]. Returns (value, next index)."""
    n = len(text)
    if i < n and text[i] == "'":
        j = text.find("'", i + 1)
        if j < 0:
            return text[i + 1 :], n
        return text[i + 1 : j], j + 1
    if i < n and text[i] == '"':
        i += 1
        out: list[str] = []
        while i < n and text[i] != '"':
            if text[i] == "\\" and i + 1 < n and text[i + 1] in _ESCAPES:
                out.append(_ESCAPES[text[i + 1]])
                i += 2
            else:
                out.append(text[i])
                i += 1
        return "".join(out), min(i + 1, n)
    j = text.find("\n", i)
    if j < 0:
        j = n
    return text[i:j], j


def parse_conf(text: str) -> dict[str, str]:
    """Parse shell-syntax KEY=value assignments without executing them."""
    out: dict[str, str] = {}
    i, n = 0, len(text)
    while i < n:
        while i < n and text[i] in " \t\n":
            i += 1
        if i >= n:
            break
        if text[i] == "#":
            i = text.find("\n", i)
            if i < 0:
                break
            continue
        j = i
        while j < n and (text[j].isalnum() or text[j] == "_"):
            j += 1
        if j > i and j < n and text[j] == "=":
            val, nxt = _value(text, j + 1)
            out[text[i:j]] = val
            i = nxt
            continue
        i = text.find("\n", i)
        if i < 0:
            break
    return out


# The rules are written for grep -E, which knows POSIX character classes and
# Python's re does not: without this, "[[:space:]]" would be a class of the six
# letters s, p, a, c and e.
POSIX_CLASSES = {
    "space": r"\s",
    "blank": r"[ \t]",
    "digit": r"\d",
    "alpha": r"[A-Za-z]",
    "alnum": r"[A-Za-z0-9]",
    "upper": r"[A-Z]",
    "lower": r"[a-z]",
    "word": r"\w",
    "xdigit": r"[0-9A-Fa-f]",
    "punct": r"[^\w\s]",
    "cntrl": r"[\x00-\x1f\x7f]",
    "print": r"[^\x00-\x1f\x7f]",
    "graph": r"[^\s\x00-\x1f\x7f]",
}


def _posix(pattern: str) -> str:
    """Rewrite `[:space:]` and friends as their Python equivalents."""
    return re.sub(
        r"\[:(\w+):\]", lambda m: POSIX_CLASSES.get(m.group(1), m.group(0)), pattern
    )


def _compile(pattern: str | None) -> re.Pattern[str] | None:
    if not pattern:
        return None
    # Rules are written for grep -Ei: case-insensitive, and line based, so ^ and
    # $ have to match at every line break and not just at the ends of the string
    # (the screen arrives as one multi-line blob).
    return re.compile(_posix(pattern), re.IGNORECASE | re.MULTILINE)


def _words(raw: str | None) -> tuple[str, ...]:
    return tuple(raw.split()) if raw else ()


@dataclass(frozen=True)
class AgentRules:
    name: str
    bins: tuple[str, ...] = ()
    path_hints: tuple[str, ...] = ()
    blocked_title: re.Pattern[str] | None = None
    blocked_screen: re.Pattern[str] | None = None
    working_title: re.Pattern[str] | None = None
    working_screen: re.Pattern[str] | None = None
    idle_screen: re.Pattern[str] | None = None
    check_order: tuple[str, ...] = ()
    title_strip: re.Pattern[str] | None = None
    title_ignore: re.Pattern[str] | None = None
    icon: str = ""
    resume: str | None = None

    @classmethod
    def from_conf(cls, name: str, text: str) -> AgentRules:
        kv = parse_conf(text)
        return cls(
            name=name,
            bins=_words(kv.get("AGENT_BINS")),
            path_hints=_words(kv.get("AGENT_PATH_HINTS")),
            blocked_title=_compile(kv.get("BLOCKED_TITLE")),
            blocked_screen=_compile(kv.get("BLOCKED_SCREEN")),
            working_title=_compile(kv.get("WORKING_TITLE")),
            working_screen=_compile(kv.get("WORKING_SCREEN")),
            idle_screen=_compile(kv.get("IDLE_SCREEN")),
            check_order=_words(kv.get("CHECK_ORDER")),
            title_strip=_compile(kv.get("TITLE_STRIP")),
            title_ignore=_compile(kv.get("AGENT_TITLE_IGNORE")),
            icon=kv.get("AGENT_ICON", ""),
            resume=kv.get("AGENT_RESUME") or None,
        )


@dataclass(frozen=True)
class RuleSet:
    rules: tuple[AgentRules, ...]
    by_bin: dict[str, AgentRules]

    @classmethod
    def load(cls, rules_dir: Path) -> RuleSet:
        rules = []
        for path in sorted(rules_dir.glob("*.conf")):
            rules.append(AgentRules.from_conf(path.stem, path.read_text()))
        by_bin: dict[str, AgentRules] = {}
        for rule in rules:
            for bin_name in rule.bins:
                by_bin[bin_name] = rule
        return cls(tuple(rules), by_bin)

    def match_bin(self, comm: str) -> AgentRules | None:
        return self.by_bin.get(comm)

    def match_argv(self, argv: list[str]) -> AgentRules | None:
        for rule in self.rules:
            for hint in rule.path_hints:
                if any(hint in arg for arg in argv):
                    return rule
        return None


# Codex renders the pane title from an ordered item list. The default items are
# the activity spinner and the project name; adding `thread-title` puts the
# session name there too, joined with " | ".
ACTION_REQUIRED = "Action Required"
BRAILLE_SPINNER = re.compile("^[\u2800-\u28ff]\\s*")
# Codex renders the thread identifier when a session has no title yet.
THREAD_IDENTIFIER = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
TITLE_SEPARATOR = " | "


def _strip_spinner(rule: AgentRules, text: str) -> str:
    """Drop a leading activity spinner.

    The rules' TITLE_STRIP is anchored and expects a trailing space, so a bare
    braille spinner needs its own pass.
    """
    if rule.title_strip:
        text = rule.title_strip.sub("", text)
    return BRAILLE_SPINNER.sub("", text.strip()).strip(" |-")


def subject(rule: AgentRules, title: str, cwd: str = "") -> str:
    """Best effort session name for a pane, empty when there is none.

    Only the pane title can name a session reliably: the agent's own session
    files record the cwd, not the pane, so two agents started in the same
    directory are indistinguishable by file lookup. That is why this reads the
    title, and why Codex needs `[tui] terminal_title` to include `thread-title`.
    """
    text = _strip_spinner(rule, title)
    if text.startswith(ACTION_REQUIRED):
        text = _strip_spinner(rule, text[len(ACTION_REQUIRED):])
    base = cwd.rsplit("/", 1)[-1] if cwd else ""
    # tmux titles a pane with the hostname until an application names it, which
    # says nothing about the session.
    host = socket.gethostname()
    # Titles are "a | b | c"; keep the first part that can be a name, so the
    # name is found whether it sits before or after the project.
    for part in text.split(TITLE_SEPARATOR):
        part = part.strip(" |-")
        if not part or THREAD_IDENTIFIER.match(part):
            continue
        # An agent with a plain title echoes the directory or its own name;
        # neither of those is a session name. OpenCode titles its pane with
        # just "OpenCode", hence the case-insensitive comparison.
        if part == base or part.lower() == rule.name.lower() or part == host:
            continue
        # Some agents put their own name in the title, or a fixed banner.
        if rule.title_ignore is not None and rule.title_ignore.fullmatch(part):
            continue
        # Agents truncate a long directory echo with an ellipsis.
        if base and part.endswith(("...", "\u2026")) and base.startswith(part.rstrip(".\u2026")):
            continue
        return part
    return ""


def screen_tail(screen: str) -> str:
    """Last SCREEN_TAIL_LINES lines, with non-breaking spaces normalised.

    Agents pad prompt lines with U+00A0, which an ASCII [[:space:]] would miss.
    """
    lines = screen.rstrip("\n").split("\n")
    return "\n".join(lines[-SCREEN_TAIL_LINES:]).replace("\u00a0", " ")


def _hit(rx: re.Pattern[str] | None, text: str) -> bool:
    return rx is not None and rx.search(text) is not None


def _state_for(check: str, rule: AgentRules, title: str, screen: str) -> str | None:
    if check == "bt":
        return WAITING if _hit(rule.blocked_title, title) else None
    if check == "bs":
        return WAITING if _hit(rule.blocked_screen, screen) else None
    if check == "wt":
        return WORKING if _hit(rule.working_title, title) else None
    if check == "ws":
        return WORKING if _hit(rule.working_screen, screen) else None
    if check == "is":
        return IDLE if _hit(rule.idle_screen, screen) else None
    return None


def resolve_title_only(rule: AgentRules, title: str) -> tuple[str, str] | None:
    """Settle a pane from its title alone, or return None if a screen is needed.

    Codex titles the pane with a braille spinner while it works, so a working
    pane costs no capture-pane call at all.
    """
    for check in rule.check_order or DEFAULT_ORDER:
        if check in SCREEN_CHECKS:
            return None
        state = _state_for(check, rule, title, "")
        if state is not None:
            return state, check
    return None


def resolve_state(
    rule: AgentRules,
    title: str,
    get_screen=None,
) -> tuple[str, str]:
    """Return (state, reason), walking CHECK_ORDER, first hit wins.

    get_screen() is called at most once and only when a screen check is
    actually reached, so title-only hits (for example Codex spinning while it
    works) cost no capture-pane call at all.
    """
    screen: str | None = None
    for check in rule.check_order or DEFAULT_ORDER:
        if check in SCREEN_CHECKS and screen is None:
            screen = screen_tail(get_screen() if get_screen else "")
        state = _state_for(check, rule, title, screen or "")
        if state is not None:
            return state, check
    return IDLE, "default"


def detect_state(rule: AgentRules, title: str, screen: str) -> tuple[str, str]:
    """Convenience wrapper for tests and offline callers."""
    return resolve_state(rule, title, lambda: screen)

"""Republish Codex Wayland clipboard entries through wl-copy.

Symptoms
--------
Copying output from Codex shows Ghostty's "Copied to clipboard" toast, but
Ctrl+Shift+V in Ghostty or Neovim immediately afterwards does nothing. Pasting
the same content into Kate works. After that, returning to Ghostty and pasting
also works. Native X11 environments do not reproduce the problem.

Cause
-----
When Codex's fullscreen transcript owns mouse selection, Codex copies through
its own clipboard backend. That backend combines native arboard access with
tmux or OSC 52 forwarding. On Wayland, the resulting clipboard can expose a
rich, X11-compatible target set that Ghostty cannot read through its native
Wayland path.

The text is present. This is not an empty clipboard or a broken Ghostty
keybinding. Another Wayland client, such as Kate, can request a target that the
owner serves and causes Klipper to republish the content in a form Ghostty can
read. That is why pasting in Kate repairs the next Ghostty paste.

The problem requires the Wayland clipboard bridge. A native X11 session uses a
different ownership and target negotiation path, so X11 hosts do not reproduce
it.

Workarounds
-----------
- Hold Shift, select text with the mouse, then press Ctrl+Shift+C. This makes
  the terminal own the selection and bypasses Codex's clipboard backend.
- After Codex copies, run `wl-paste -n | wl-copy` to republish the clipboard
  through the normal Wayland provider.
- Run this service to perform the republish automatically.

`/copy` uses the same backend as Codex's own selection copy. No Codex setting
switches `/copy` to terminal-native copying or changes its format. Codex hooks
do not fire for `/copy`, because it is a local TUI action rather than a model
turn, prompt submission, or tool call.

Service behavior
----------------
Home Manager starts `wl-paste --type text/plain --watch` for this script. The
script only acts when the clipboard offers the rich legacy target set produced
by the Codex failure: text/html, STRING, UTF8_STRING, and TEXT. It republishes
the exact stdin bytes with wl-copy. A five-second SHA-256 cooldown prevents the
republished clipboard from triggering a feedback loop. Empty content and
sensitive clipboard states are ignored.

Tradeoff
--------
Affected entries are republished as text/plain, so rich HTML formatting is not
preserved. Terminal paste only needs text. Disable this workaround with
`clj.programs.ghostty.normalizeClipboard = false` after Codex fixes the
backend.

Upstream reports
----------------
- https://github.com/openai/codex/issues/40825
  Clipboard owner advertises text targets it refuses to serve.
- https://github.com/openai/codex/issues/48139
  TUI copy and paste shortcut problems, including the Shift selection
  workaround:
  https://github.com/openai/codex/issues/48139#issuecomment-6242012263
- https://github.com/openai/codex/issues/53208
  Request for an option to always copy through the terminal via OSC 52.
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path

COOLDOWN_NS = 5_000_000_000
STATE_FILE = "wayland-clipboard-normalizer.json"
CODEX_LEGACY_TARGETS = frozenset({"STRING", "UTF8_STRING", "TEXT"})


def log(message: str) -> None:
    print(
        f"wayland-clipboard-normalizer: {message}",
        file=sys.stderr,
        flush=True,
    )


def offered_types(wl_paste: str) -> set[str]:
    result = subprocess.run(
        [wl_paste, "--list-types"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        log(f"wl-paste --list-types failed: {result.stderr.strip()}")
        return set()
    return set(result.stdout.splitlines())


def state_path() -> Path:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if not runtime_dir:
        raise RuntimeError("XDG_RUNTIME_DIR is not set")
    return Path(runtime_dir) / STATE_FILE


def recently_republished(content_hash: str) -> bool:
    path = state_path()
    try:
        state = json.loads(path.read_text())
        previous_hash = state["hash"]
        previous_time = int(state["time_ns"])
    except (
        FileNotFoundError,
        KeyError,
        TypeError,
        ValueError,
        json.JSONDecodeError,
    ):
        return False

    elapsed = time.time_ns() - previous_time
    return previous_hash == content_hash and 0 <= elapsed < COOLDOWN_NS


def record_republish(content_hash: str) -> None:
    path = state_path()
    path.write_text(
        json.dumps({"hash": content_hash, "time_ns": time.time_ns()}) + "\n"
    )


def main() -> int:
    if os.environ.get("CLIPBOARD_STATE") != "data":
        return 0

    content = sys.stdin.buffer.read()
    if not content:
        return 0

    wl_paste = os.environ.get("WL_PASTE", "wl-paste")
    wl_copy = os.environ.get("WL_COPY", "wl-copy")

    types = offered_types(wl_paste)
    if "text/html" not in types or not CODEX_LEGACY_TARGETS.issubset(types):
        return 0

    content_hash = hashlib.sha256(content).hexdigest()
    if recently_republished(content_hash):
        return 0

    result = subprocess.run([wl_copy], input=content, check=False)
    if result.returncode != 0:
        log(f"wl-copy failed with status {result.returncode}")
        return 1

    record_republish(content_hash)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

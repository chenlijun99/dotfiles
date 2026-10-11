# Design record

Decisions behind this tool, what phase 1 delivers, and what phase 2 is allowed
to assume. Written so that phase 2 can be built without re-opening settled
questions.

## Problem

Five or six tmux windows per repo, the last of them running coding agents, and
no way to see which agent is working, which is stuck, and which is waiting on
you. Plus unreliable desktop notifications: tmux only renders the active pane,
so an OSC notification emitted by an agent in a hidden window never reaches the
terminal.

## Settled decisions

| Decision | Choice | Why |
| --- | --- | --- |
| Scope order | overview popup first, notifications and concurrency later | the overview is the daily pain; notifications depend on the same state source |
| Detection | hook-free, from the pane title and pane screen | nothing to install into the agents, works for any agent, survives CLI updates |
| Reuse | vendor agenmux's rule files verbatim (MIT), one per agent (claude, codex, opencode), implement detection in Python | no crate exists to depend on; agenmux is a single binary crate, not published to crates.io |
| Shape | one-shot `scan.py` emitting TSV or JSON | a phase-2 daemon, a status-line badge and notifications all consume the same output |
| Home | `src/tmux/agents/` in the dotfiles repo, packaged by its `default.nix` | ships with the tmux config, and the tmux module installs the CLI so the binding calls a command rather than a path |
| UI | `display-popup` plus fzf, previewing by switching the client to the selected pane | tmux 3.7 and fzf are already installed; a text capture of a full screen TUI makes a poor preview, so the preview is the real pane (the tmux-fzf approach) |

Rejected: adopting ccmux / agent-deck / agent-manager (a whole cockpit and, in
agent-manager's case, its own tmux sessions, which fights the one-session-per
repo convention), packaging agenmux as-is (Rust plus a prebuilt-binary
installer, and it wants to be a sidebar), and using Codex's native `codex
agents` (Codex-only, no jump to pane, no repo or window awareness).

## Rendering

Each row is one display line, padded to the columns the popup's list can show
(`list_width()`, the popup's columns minus fzf's border, its scrollbar column
and the two columns of its truncation marker). The age is placed against that
right edge, so it lines up across rows and, when a row is too long, the session
name is what gets cut.

The target (pane id, session, window index) is in the hidden fields 1 to 3, and
the display line is field 4; fzf numbers fields after `--with-nth`, so the
searchable range is `--nth=1`, which is exactly the visible line.

## Detection contract

`clj_agents scan --format=json` is the interface phase 2 builds on. One object per
agent pane:

```json
{
  "pane_id": "%1", "session": "homelab", "window_index": "5",
  "window_name": "misc", "agent": "codex", "state": "working",
  "reason": "wt", "cwd": "/home/lijun/Repositories/personal/homelab",
  "age": 12, "title": "\u283c Organize AI agents in tmux",
  "subject": "Organize AI agents in tmux"
}
```

`state` is `working`, `waiting` or `idle`. `reason` is the check that fired
(`bt`, `wt`, `bs`, `ws`, `is`, or `default`), which lets a consumer tell a
permission prompt apart from a question or an error without re-parsing the
screen. `age` is seconds since the window's last output, so it is per window
rather than per pane: tmux exposes no per-pane activity format.

`subject` is the agent's own session name, read out of the pane title. That is
the only per-pane source there is: the session files Codex writes record a cwd
and a session id, never a pane, and the rollout file is not held open either, so
two Codex sessions started in the same directory cannot be told apart from the
filesystem. It therefore depends on Codex printing the thread title in the pane
title (`[tui] terminal_title = ["activity", "project-name", "thread-title"]`, set in
the dotfiles codex module), and is empty without it. Codex prints the thread id
while a session is unnamed, so a bare UUID is treated as "no name".

## Phase 1 (done)

`clj_agents` (a CLI with `scan` and `popup`), vendored rules, 53 unit tests
with screen fixtures, and `bind Space` in tmux.conf. `working` panes are
classified from the title alone, so they cost no `capture-pane` call.

The picker previews by moving the client onto the selected pane as the cursor
moves, rather than rendering a capture, and puts the client back on `esc` or
`ctrl-c` (previous session included), re-reading the client's session between
the two history switches because the first switch changes what the second has to
do. Opening it does not move you: the pane you are on is preselected when it is
an agent pane, and when it is not, a placeholder row goes first. That
placeholder targets the pane you came from, so returning to it previews that
pane again, and fzf's unavoidable startup `focus` event lands on something that
is not a row. There is no refresh key: the list is a snapshot taken when the
popup opens, and the live preview is what you look at to see what changed.

## Phase 2 (not started)

Nothing in phase 1 needs to change for any of these; they all read `scan.py`.

1. **Notifications.** Still open, and deliberately so. The three viable
   channels are a tmux hook on `alert-bell` / `alert-silence`, a small watcher
   daemon that fires D-Bus notifications from state transitions, or Codex's own
   `[tui.notifications]` (`notification_method`, `notification_condition`)
   combined with the first. The likely answer is a watcher with the noise rules
   "only on turn completion, only when that pane is not the one in view, and
   only if the turn ran longer than ~20s". Root cause of the current
   flakiness is understood: hidden panes' escape sequences never reach the
   terminal.
2. **`last-seen` markers**, so a pane that finished while you were elsewhere
   can be shown differently from one that has been idle all along. Needs a
   small state file, so it belongs with the watcher.
3. **Send a message without attaching**, which is what makes "answer an agent
   without losing your place" real.
4. **Concurrency.** Three wrappers rather than a tree UI: `codex queue` for an
   asynchronous follow-up, `codex fork` (or a side conversation) for a branch
   that shares context, and a keybinding to spawn a throwaway side agent in a
   new window. The fork relationships exist in Codex's data model
   (`forked_from_id`, `parent_thread_id`, agent paths) and can be displayed
   later; tmux should not own them.
5. **Subjects.** `TITLE_STRIP` and the `SUBJECT_SCREEN` / `SUBJECT_CMD` keys
   are already parsed. Codex's subject lives in the newest rollout file for the
   pane's cwd, which costs a shell fork per pane, so it belongs behind a cache.

## Deviations from the agreed plan

- The binding is `prefix Space`. `o` looked free but is `select-pane -t :.+`
  (a tmux default), and Space is the better key anyway: it became available
  once tmux-easy-motion was removed as unused. Space would otherwise be the
  stock `next-layout`, so that is what it costs.
- The internal `blocked` state is presented as `waiting`.
- `DESIGN.md` plus `README.md` were written together rather than committing the
  design first, since the plan was already agreed in conversation.

## Known limitations

- `NO_COLOR` in the environment strips fzf's colours, as with any fzf UI.
- The age column is per window, not per pane (see above).
- Detection is regex based, so an agent that changes its spinner glyphs or
  prompt text needs its `rules/<agent>.conf` updated. That is the trade for
  having no hooks.
- The live preview moves your client, so a second attached client is left alone
  on purpose: only the client that opened the popup is switched. With no client
  (running `popup.py` by hand) it falls back to a static `capture-pane` preview.
- The client and pane the popup works on are captured by the binding, not read
  from inside the popup: tmux resolves `#{client_*}` and `#{pane_id}` inside a
  popup against whichever client typed last, so a second attached client broke
  both the preview and the restore. The binding therefore goes through
  `run-shell`, where the formats are expanded for the client that pressed the
  key, and opens the popup with an explicit `-c` for that client. Running
  `popup.py` by hand falls back to the formats, which is only correct with one
  client attached.
- The session-name column depends on Codex's `terminal_title` (`thread-title`).
  Without it the column is empty; nothing else degrades.

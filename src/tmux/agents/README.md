# agents

A tmux popup that answers "which coding agents are running, and what are they
doing?" across every session on the server, plus a jump and a kill.

Detection is **hook-free**. It reads only what tmux already knows (the pane
title and the last lines of the pane screen) and installs nothing into the
agents. That is possible because the agents advertise their state on the
screen they draw: Codex rotates a braille spinner into the pane title while it
works, and all of them print an interrupt hint, or a permission prompt, while they
run.

```
prefix (M-a) Space
```

## What you get

```
> working homelab:5           codex    agent-popup                       12s
  idle    obsidian-personal:2 codex    Test the implementation            2m
  waiting agentsbench:1       opencode                                    2h
```

The age is against the right edge of the popup, and the session name gives way
before it when a row runs out of room.

Entries are listed waiting first, then idle, then working, because the pane that
is waiting on you is the one you are looking for.

| Key | Action |
| --- | --- |
| `enter` | keep the selected pane (the preview already took you there) |
| `esc`, `ctrl-c` | close, and put your client back on the pane it started on |
| `ctrl-x` | kill that pane, after a confirmation |
| type | filter by session, agent, window or session name |
| arrows / `ctrl-n` `ctrl-p` | move |

Opening the popup does not move you: when the pane you are on is an agent, that
row is preselected and previewed, and when it is not, the client stays put until
you move the cursor.

The preview is the **real pane**. On every focus event the client is switched to
that agent, so the screen around the popup is the agent's live screen instead of
a text capture (the trick `tmux-fzf` uses). The popup is `-w 60% -h 60%` in
`tmux.conf`; shrink it if you want to see more of the pane.

## Session names

The last column is the agent's own session name, and it comes from the pane
title. Only the pane title can name a session reliably: the agents' session
files record a directory, not a pane, so two agents started in the same
directory cannot be told apart that way, and Codex pairs a pane with its
session in no other place we can read.

For Codex that means asking it to put the thread title in the title (Claude
Code puts a task summary there when it has one; the app name, the hostname tmux
shows by default, and a plain directory echo all count as "no name"):

```toml
[tui]
terminal_title = ["activity", "project-name", "thread-title"]
```

This is set in `src/nixos/modules/ai/codex/default.nix` next to your
`status_line`, so it arrives with a home-manager switch, and it is in the live
`~/.codex/config.toml` too. A Codex session only reads the config at startup, so
already running sessions keep their old title until they are restarted.

Codex prints the thread id in place of the title until a session has been
named; the popup shows nothing rather than a UUID. Without the setting at all
the column is simply empty, and everything else works.

## States

| State | Meaning | How it is detected |
| --- | --- | --- |
| `working` | the agent is running a turn | a spinner in the pane title (Codex and Claude Code), or an interrupt hint on screen (`esc to interrupt`, OpenCode's progress blocks) |
| `waiting` | the agent is blocked on you | Codex's `Action Required` title, or a permission or confirmation prompt on screen |
| `idle` | the agent has the prompt and is waiting for your next message | none of the above |

Each agent's `CHECK_ORDER` decides what to look at first, so a Codex or Claude
Code pane that is working is classified with **no** `capture-pane` call at all,
and Claude Code's idle prompt is checked before its permission prompts, since an
answered prompt lingers on screen.

Because the agents run with `--dangerously-bypass-approvals-and-sandbox`, an
`idle` pane is almost always the "I am done, your turn" signal, and `waiting`
is reserved for questions, errors and unexpected prompts.

## The CLI

`default.nix` builds this directory into a package whose only entry point is
`clj_agents`, installed by `src/nixos/modules/programs/tmux.nix`:

```sh
clj_agents scan                     # TSV, one row per coding-agent pane
clj_agents scan --format=json | jq .
clj_agents popup                    # what `bind Space` runs, inside display-popup
clj_agents scan --rules ./somewhere # try edited rules before rebuilding
```

| File | Purpose |
| --- | --- |
| `default.nix` | the derivation: the package and its tests |
| `clj_agents/cli.py` | argument parsing and dispatch for `scan` and `popup` |
| `clj_agents/detect.py` | rule parsing and the state machine. Pure, no tmux, unit tested |
| `clj_agents/scan.py` | tmux and process I/O, and the row formats |
| `clj_agents/popup.py` | the fzf UI: list, live preview, jump, kill |
| `clj_agents/rules/*.conf` | per-agent detection rules, vendored (see below) |
| `tests/` | unit tests and screen fixtures |

`scan` is the single source of truth for status. Phase 2 (a watcher feeding
notifications and a status-line badge) consumes the same output, so nothing in
the popup has to change.

```sh
python3 -m clj_agents scan                      # in a checkout, no install needed
python3 -B -m unittest discover -s tests -v     # -B: keep bytecode out of the repo
nix-build -E 'with import <nixpkgs> {}; callPackage ./src/tmux/agents {}'
```

## Adding an agent

Detection is data, not code. Drop `rules/<agent>.conf` with
`AGENT_BINS`, the `*_TITLE` and `*_SCREEN` regexes, `CHECK_ORDER`, and
optionally `AGENT_RESUME`, and the popup picks it up. The conf format is the
agenmux one: shell syntax, parsed without executing anything, and values may be
multi-line single-quoted strings. `TITLE_STRIP` is used to pull the session
name out of the title; the `SUBJECT_*` keys are parsed but not used yet (the
session name comes from the title, not from the session files). Rules live
inside the package, so a new agent needs a `home-manager switch`, or a run with
`--rules`.

## Requirements

`clj_agents` (this directory) and `fzf`, both installed by
`src/nixos/modules/programs/tmux.nix`, which also needs a `home-manager switch`
before `bind Space` finds the command. tmux 3.2 or newer for `display-popup`.
Codex needs `terminal_title` to include `thread-title` for the session-name
column, set in `src/nixos/modules/ai/codex/default.nix` (see above); nothing
else is configured inside the agents.

## Vendored rules and attribution

`clj_agents/rules/{claude,codex,opencode}.conf` are copied verbatim from
[snirt/agenmux](https://github.com/snirt/agenmux) (MIT) at commit
`cd82d6525bce6ec71f3995ea7aa367ebca2ea9bd`, which ports herdr's detection
manifests. See `rules/LICENSE.agenmux`.

`claude.conf` carries one local addition, marked as such: `AGENT_TITLE_IGNORE="Claude Code"`,
because Claude Code titles its pane with just the app name when a session has no
task summary, and that is not a session name. The same key would work for any
other agent that puts a fixed banner in the title. Claude Code is covered by
tests and by simulated panes; it is not installed on this machine, so it has not
been exercised against a live session.

Codex also exposes a first-class `[hooks]` system (`agent-turn-complete`,
`approval-requested`, `async-question`). We do not use it: the whole point here
is that status works with zero configuration inside the agents. If exact
per-turn events are ever wanted for notifications, the hook route stays open
and can feed the same state cache.

## Performance

Measured on this machine, 35 panes of which 31 were agent panes, 9 runs each:

| Scenario | Median | Range |
| --- | --- | --- |
| 30 panes needing a screen capture | ~64 ms | 61 to 78 ms |
| 30 panes settled by title alone | ~50 ms | 46 to 53 ms |
| `tmux list-panes -a` alone | ~3 ms | 3 to 5 ms |
| bare `python3` start | ~15 ms | |

So roughly 15 ms is interpreter startup, ~3 ms is the tmux query, and the work
this tool adds on top is about 30 ms at 30 agents. One `list-panes` call finds
the candidates, captures are sharded across a bounded number of threads, and
panes whose title already settles the state are never captured.

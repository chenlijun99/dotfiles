#!/usr/bin/env python3
"""Unit tests for hook-free agent detection.

Run from the project root with:  python3 -m unittest discover -s tests -v
"""

from __future__ import annotations

import os
import re
import socket
import sys
import unittest
import unittest.mock
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]      # holds the clj_agents package
sys.path.insert(0, str(ROOT))

from clj_agents import detect, popup, scan  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"

# Pane titles as the agents actually set them. Codex rotates a braille spinner
# while it works and titles the pane with the directory when it is idle.
CODEX_SPINNER = "\u283c homelab"
CODEX_IDLE_TITLE = "homelab"
CODEX_ACTION_REQUIRED = "Action Required"
OPENCODE_TITLE = "OC | myproject"


def fixture(name: str) -> str:
    return (FIXTURES / name).read_text()


class RuleSetTests(unittest.TestCase):
    def setUp(self) -> None:
        self.rules = detect.RuleSet.load(scan.RULES_DIR)

    def test_registers_the_shipped_agents(self) -> None:
        self.assertEqual({r.name for r in self.rules.rules}, {"claude", "codex", "opencode"})

    def test_bins_are_parseable_process_names(self) -> None:
        self.assertIsNotNone(self.rules.match_bin("claude"))
        self.assertIsNotNone(self.rules.match_bin("codex"))
        self.assertIsNotNone(self.rules.match_bin("opencode"))
        self.assertIsNotNone(self.rules.match_bin("open-code"))
        self.assertIsNone(self.rules.match_bin("vim"))

    def test_multi_line_values_do_not_break_later_keys(self) -> None:
        # codex.conf carries a multi-line single-quoted SUBJECT_CMD.
        codex = self.rules.match_bin("codex")
        self.assertIsNotNone(codex)
        self.assertEqual(codex.resume, "codex resume --last")
        self.assertIsNotNone(codex.working_title)

    def test_parse_conf_handles_quotes_comments_and_bare_values(self) -> None:
        text = "\n".join(
            [
                "# a comment",
                "A='verbatim \"quoted\" $HOME'",
                'B="escaped \\" quote" # trailing comment',
                "C=bare",
                "D='multi",
                "line'",
                "E=\"escaped \\$dollar\"",
            ]
        )
        kv = detect.parse_conf(text)
        self.assertEqual(kv["A"], 'verbatim "quoted" $HOME')
        self.assertEqual(kv["B"], 'escaped " quote')
        self.assertEqual(kv["C"], "bare")
        self.assertEqual(kv["D"], "multi\nline")
        self.assertEqual(kv["E"], "escaped $dollar")


class CodexStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.codex = detect.RuleSet.load(scan.RULES_DIR).match_bin("codex")

    def test_spinner_title_is_working_without_reading_the_screen(self) -> None:
        self.assertEqual(detect.resolve_title_only(self.codex, CODEX_SPINNER), ("working", "wt"))

    def test_idle_title_and_calm_screen_is_idle(self) -> None:
        screen = fixture("codex_idle.txt")
        self.assertEqual(detect.detect_state(self.codex, CODEX_IDLE_TITLE, screen), ("idle", "default"))

    def test_working_screen_is_working(self) -> None:
        screen = fixture("codex_working.txt")
        self.assertEqual(detect.detect_state(self.codex, CODEX_IDLE_TITLE, screen), ("working", "ws"))

    def test_blocked_screen_is_waiting(self) -> None:
        screen = fixture("codex_blocked.txt")
        self.assertEqual(detect.detect_state(self.codex, CODEX_IDLE_TITLE, screen), ("waiting", "bs"))

    def test_action_required_title_beats_a_working_screen(self) -> None:
        # CHECK_ORDER is "bt wt bs ws": the blocked title wins outright.
        screen = fixture("codex_working.txt")
        self.assertEqual(
            detect.detect_state(self.codex, CODEX_ACTION_REQUIRED, screen), ("waiting", "bt")
        )

    def test_spinner_title_beats_a_blocked_looking_screen(self) -> None:
        # bt then wt run before any screen check, so a stale prompt on screen
        # cannot downgrade a pane that is actively working.
        screen = fixture("codex_blocked.txt")
        self.assertEqual(
            detect.detect_state(self.codex, CODEX_SPINNER, screen), ("working", "wt")
        )


class ClaudeStateTests(unittest.TestCase):
    """Claude Code, whose rules lean on the screen more than the title."""

    def setUp(self) -> None:
        self.claude = detect.RuleSet.load(scan.RULES_DIR).match_bin("claude")

    def test_bins(self) -> None:
        self.assertIsNotNone(self.claude)
        self.assertIsNotNone(detect.RuleSet.load(scan.RULES_DIR).match_bin("claude-code"))

    def test_working_screen_is_working(self) -> None:
        self.assertEqual(
            detect.detect_state(self.claude, "Claude Code", fixture("claude_working.txt")),
            ("working", "ws"),
        )

    def test_spinner_title_is_working_without_reading_the_screen(self) -> None:
        self.assertEqual(
            detect.resolve_title_only(self.claude, "\u280b Fix the parser"), ("working", "wt")
        )

    def test_idle_prompt_is_idle(self) -> None:
        self.assertEqual(
            detect.detect_state(self.claude, "Claude Code", fixture("claude_idle.txt")),
            ("idle", "is"),
        )

    def test_permission_prompt_is_waiting(self) -> None:
        self.assertEqual(
            detect.detect_state(self.claude, "Claude Code", fixture("claude_blocked.txt")),
            ("waiting", "bs"),
        )

    def test_an_answered_prompt_does_not_read_as_blocked(self) -> None:
        # CHECK_ORDER is "wt ws is bs": the idle prompt wins over the permission
        # text that is still on screen above it.
        self.assertEqual(
            detect.detect_state(self.claude, "Claude Code", fixture("claude_answered.txt")),
            ("idle", "is"),
        )

    def test_the_subject_strips_the_status_glyph(self) -> None:
        self.assertEqual(detect.subject(self.claude, "\u280b Fix the parser", "/tmp/x"),
                         "Fix the parser")

    def test_the_default_tmux_title_is_not_a_session_name(self) -> None:
        # tmux titles a pane with the hostname until an application names it.
        with unittest.mock.patch.object(socket, "gethostname", lambda: "dell-precision"):
            self.assertEqual(detect.subject(self.claude, "dell-precision", "/tmp/x"), "")

    def test_the_app_name_is_not_a_session_name(self) -> None:
        self.assertEqual(detect.subject(self.claude, "\u280b Claude Code", "/tmp/x"), "")


class OpenCodeStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.opencode = detect.RuleSet.load(scan.RULES_DIR).match_bin("opencode")

    def test_working_screen_is_working(self) -> None:
        screen = fixture("opencode_working.txt")
        self.assertEqual(detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("working", "ws"))

    def test_blocked_screen_is_waiting(self) -> None:
        screen = fixture("opencode_blocked.txt")
        self.assertEqual(detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("waiting", "bs"))

    def test_idle_screen_is_idle(self) -> None:
        screen = fixture("opencode_idle.txt")
        self.assertEqual(detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("idle", "default"))

    def test_matching_is_case_insensitive_like_grep_ei(self) -> None:
        screen = "\u25b3 PERMISSION REQUIRED\n"
        self.assertEqual(detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("waiting", "bs"))

    def test_screen_needs_no_title_rule(self) -> None:
        self.assertIsNone(detect.resolve_title_only(self.opencode, OPENCODE_TITLE))


class ScreenWindowTests(unittest.TestCase):
    def setUp(self) -> None:
        self.opencode = detect.RuleSet.load(scan.RULES_DIR).match_bin("opencode")

    def test_only_the_last_twenty_lines_are_considered(self) -> None:
        screen = "esc to interrupt\n" + "x\n" * 25
        self.assertEqual(
            detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("idle", "default")
        )

    def test_a_hit_inside_the_last_twenty_lines_counts(self) -> None:
        screen = "esc to interrupt\n" + "x\n" * 19
        self.assertEqual(
            detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("working", "ws")
        )

    def test_trailing_blank_rows_do_not_hide_activity(self) -> None:
        screen = "esc to interrupt\n" + "\n" * 25
        self.assertEqual(
            detect.detect_state(self.opencode, OPENCODE_TITLE, screen), ("working", "ws")
        )

    def test_non_breaking_spaces_are_normalised(self) -> None:
        rule = detect.AgentRules.from_conf("synthetic", "IDLE_SCREEN='^\u276f $'\nCHECK_ORDER=\"is\"\n")
        self.assertEqual(detect.detect_state(rule, "", "\u276f\u00a0\n"), ("idle", "is"))

    def test_lazy_screen_is_read_at_most_once(self) -> None:
        calls = []
        detect.resolve_state(
            self.opencode, OPENCODE_TITLE, lambda: calls.append(1) or "esc to interrupt"
        )
        self.assertEqual(len(calls), 1)


class RenderingTests(unittest.TestCase):
    def row(self, **overrides) -> scan.Row:
        base = dict(
            subject="",
            pane_id="%7",
            session="homelab",
            window_index="3",
            window_name="git",
            agent="codex",
            state=detect.WAITING,
            reason="bs",
            cwd="/home/lijun/Repositories/personal/homelab",
            age=125,
            title="homelab",
        )
        base.update(overrides)
        return scan.Row(**base)

    def test_fzf_row_leads_with_the_machine_readable_target(self) -> None:
        # Fields 1 to 3 are what the fzf bindings interpolate: pane, session,
        # window. Field 4 is the whole display line.
        fields = scan.fzf_rows([self.row()])[0].split("\t")
        self.assertEqual(len(fields), 4)
        self.assertEqual(fields[0], "%7")
        self.assertEqual(fields[1], "homelab")
        self.assertEqual(fields[2], "3")

    def test_fzf_line_colours_the_state_and_shows_the_other_columns(self) -> None:
        line = scan.fzf_rows([self.row(subject="Fix the parser")])[0].split("\t")[3]
        self.assertTrue(line.startswith(scan.COLORS[detect.WAITING]))
        self.assertIn("waiting", line)
        self.assertIn("homelab:3", line)
        self.assertIn("codex", line)
        self.assertIn("Fix the parser", line)

    def visible(self, line: str) -> str:
        """The line without the escape sequences around the state."""
        return re.sub(r"\x1b\[[0-9;]*m", "", line)

    def test_the_age_is_right_aligned_across_rows(self) -> None:
        # Different name lengths, same column: that is what right aligned means.
        rows = [
            self.row(subject="Fix the parser", age=125),
            self.row(subject="", age=7200),
            self.row(subject="A much longer session name than the other one", age=5),
        ]
        lines = [
            self.visible(scan.fzf_rows(rows, width=80)[i].split("\t")[3]) for i in range(3)
        ]
        self.assertEqual({len(line) for line in lines}, {80})
        for line, expected in zip(lines, ("  2m", "  2h", "  5s")):
            self.assertTrue(line.endswith(expected), repr(line))

    def test_the_other_columns_line_up_as_well(self) -> None:
        rows = [
            self.row(session="obsidian-personal", window_index="2", subject="a"),
            self.row(session="homelab", window_index="5", subject="b"),
        ]
        lines = [
            self.visible(scan.fzf_rows(rows, width=80)[i].split("\t")[3]) for i in range(2)
        ]
        # One long session name widens the column for every row rather than
        # pushing the agent, the name and the age out of line.
        self.assertEqual(lines[0].index("codex"), lines[1].index("codex"))
        self.assertEqual(len(lines[0]), len(lines[1]))
        self.assertEqual(lines[0].index(" a"), lines[1].index(" b"))

    def test_an_absurdly_long_session_name_is_cut_but_keeps_the_window(self) -> None:
        line = self.visible(
            scan.fzf_rows([self.row(session="x" * 60, window_index="3")], width=120)[0].split("\t")[3]
        )
        self.assertIn("\u2026:3", line)
        self.assertTrue(line.endswith("  2m"), repr(line))

    def test_a_long_session_name_gives_way_before_the_age(self) -> None:
        line = self.visible(scan.fzf_rows([self.row(subject="x" * 200)], width=60)[0].split("\t")[3])
        self.assertEqual(len(line), 60)
        self.assertTrue(line.endswith("  2m"), repr(line))

    def test_fzf_row_no_longer_shows_the_cwd(self) -> None:
        line = scan.fzf_rows([self.row()])[0]
        self.assertNotIn("/home/lijun", line)

    def test_tsv_row_carries_the_session_name(self) -> None:
        fields = scan.tsv_rows([self.row(subject="Fix the parser")])[0].split("\t")
        self.assertEqual(len(fields), 11)
        self.assertEqual(fields[10], "Fix the parser")

    def test_tsv_row_has_the_documented_columns(self) -> None:
        fields = scan.tsv_rows([self.row()])[0].split("\t")
        self.assertEqual(len(fields), 11)
        self.assertEqual(fields[0], "%7")
        self.assertEqual(fields[5], "waiting")
        self.assertEqual(fields[6], "bs")
        self.assertEqual(fields[8], "125")

    def test_age_formatting(self) -> None:
        self.assertEqual(scan.age_str(0), "0s")
        self.assertEqual(scan.age_str(59), "59s")
        self.assertEqual(scan.age_str(125), "2m")
        self.assertEqual(scan.age_str(7200), "2h")
        self.assertEqual(scan.age_str(172800), "2d")
        self.assertEqual(scan.age_str(None), "-")

    def test_waiting_sorts_before_idle_and_working(self) -> None:
        self.assertLess(detect.STATE_RANK[detect.WAITING], detect.STATE_RANK[detect.IDLE])
        self.assertLess(detect.STATE_RANK[detect.IDLE], detect.STATE_RANK[detect.WORKING])


class LivePreviewPlanTests(unittest.TestCase):
    """The popup previews by moving the client, so the plans must be exact."""

    def setUp(self) -> None:
        self.popup = popup

    def test_client_ref_prefers_what_the_binding_captured(self) -> None:
        # Inside a popup tmux resolves #{client_*} against whichever client
        # typed last, so the binding passes the right one in the environment.
        env = {
            "AGENTS_CLIENT": "/dev/pts/9",
            "AGENTS_SESSION": "homelab",
            "AGENTS_WINDOW": "2",
            "AGENTS_PANE": "%4",
            "AGENTS_PREV_SESSION": "notes",
        }
        with unittest.mock.patch.dict(os.environ, env):
            ref = self.popup.client_ref()
        self.assertEqual(
            ref, self.popup.ClientRef("/dev/pts/9", "homelab", "2", "%4", "notes")
        )

    def test_client_ref_falls_back_to_formats_when_run_by_hand(self) -> None:
        raw = "/dev/pts/9\x1fhomelab\x1f2\x1f%4\x1fnotes\n"
        with unittest.mock.patch.dict(os.environ, {"AGENTS_CLIENT": ""}), unittest.mock.patch.object(
            self.popup, "tmux_out", lambda *args: raw
        ):
            ref = self.popup.client_ref()
        self.assertEqual(
            ref, self.popup.ClientRef("/dev/pts/9", "homelab", "2", "%4", "notes")
        )

    def test_switch_selects_the_pane_then_the_client(self) -> None:
        self.assertEqual(
            self.popup.switch_plan("bench", "2", "%9", "/dev/pts/8"),
            [
                ["select-pane", "-t", "%9"],
                ["switch-client", "-c", "/dev/pts/8", "-t", "bench:2"],
            ],
        )

    def record(self, orig, queries):
        """Run restore with a scripted client state and record the commands."""
        commands = []
        state = list(queries)

        def query():
            return state.pop(0) if state else ("", "")

        self.popup.restore(orig, run=commands.extend, query=query)
        return commands

    def test_restore_replaces_window_and_pane_without_a_session_change(self) -> None:
        orig = self.popup.ClientRef("/dev/pts/8", "homelab", "5", "%1", "")
        self.assertEqual(
            self.record(orig, [("homelab", "")]),
            [["select-window", "-t", "homelab:5"], ["select-pane", "-t", "%1"]],
        )

    def test_restore_replays_session_history_and_re_reads_in_between(self) -> None:
        # Client sits in probe with homelab as its previous session: it must
        # come back to probe, not stay on the session it walks through.
        orig = self.popup.ClientRef("/dev/pts/8", "probe", "1", "%204", "homelab")
        self.assertEqual(
            self.record(orig, [("probe", "homelab"), ("homelab", "probe")]),
            [
                ["switch-client", "-c", "/dev/pts/8", "-t", "homelab"],
                ["switch-client", "-c", "/dev/pts/8", "-t", "probe"],
                ["select-window", "-t", "probe:1"],
                ["select-pane", "-t", "%204"],
            ],
        )

    def test_restore_from_a_session_with_no_previous_one(self) -> None:
        orig = self.popup.ClientRef("/dev/pts/8", "homelab", "5", "%1", "")
        self.assertEqual(
            self.record(orig, [("bench", "")]),
            [
                ["switch-client", "-c", "/dev/pts/8", "-t", "homelab"],
                ["select-window", "-t", "homelab:5"],
                ["select-pane", "-t", "%1"],
            ],
        )

    def test_restore_does_nothing_without_a_client(self) -> None:
        self.assertEqual(self.record(self.popup.ClientRef("", "", "", "", ""), []), [])

    def test_shipped_binding_captures_the_client_at_keypress_time(self) -> None:
        # popup.py trusts these, and tmux cannot be asked from inside a popup.
        conf_path = ROOT.parents[1] / "tmux.conf"
        if not conf_path.exists():
            self.skipTest("only checks the checkout, not an installed copy")
        conf = conf_path.read_text().splitlines()
        start = next(i for i, l in enumerate(conf) if l.startswith("bind Space"))
        binding = conf[start]
        while binding.endswith("\\"):          # join the continuation lines
            start += 1
            binding += conf[start]
        self.assertIn("run-shell", binding)
        self.assertIn("-c '#{client_tty}'", binding)
        for var in ("AGENTS_CLIENT", "AGENTS_SESSION", "AGENTS_WINDOW", "AGENTS_PANE"):
            self.assertIn(f"{var}=#{{", binding)

    def test_focus_binding_moves_the_client_in_one_tmux_call(self) -> None:
        binds = [a for a in self.popup.fzf_args("/dev/pts/8", 1) if a.startswith("--bind=focus")]
        self.assertEqual(len(binds), 1)
        bind = binds[0]
        # One tmux invocation: select the pane, then move this client to it.
        self.assertIn("tmux select-pane -t {1}", bind)
        self.assertIn("\\; switch-client -c /dev/pts/8 -t {2}:{3}", bind)

    def test_refresh_is_gone(self) -> None:
        for arg in self.popup.fzf_args("/dev/pts/8", 1):
            self.assertNotIn("reload(", arg)
            self.assertNotIn("ctrl-r", arg)

    def test_the_cursor_only_preselects_when_asked(self) -> None:
        self.assertFalse([a for a in self.popup.fzf_args("/dev/pts/8", 1) if a.startswith("--bind=start:pos")])
        self.assertIn("--bind=start:pos(3)", self.popup.fzf_args("/dev/pts/8", 3))

    def test_search_covers_every_displayed_column(self) -> None:
        # fzf applies --nth to the line --with-nth produced, so the searchable
        # range is 1.. there, not 4.. (4.. searched only age and session name).
        args = self.popup.fzf_args("/dev/pts/8", 1)
        self.assertIn("--with-nth=4..", args)
        self.assertIn("--nth=1..", args)

    def test_without_a_client_it_falls_back_to_a_static_preview(self) -> None:
        args = self.popup.fzf_args("", 1)
        self.assertFalse([a for a in args if a.startswith("--bind=focus")])
        self.assertTrue([a for a in args if a.startswith("--preview=")])

    def test_placeholder_previews_the_pane_the_popup_was_opened_from(self) -> None:
        orig = self.popup.ClientRef("/dev/pts/8", "homelab", "2", "%4", "")
        fields = self.popup.placeholder_row(orig).split("\t")
        self.assertEqual(len(fields), 4)
        self.assertEqual(fields[0], "%4")        # the focus binding targets this
        self.assertEqual(fields[1], "homelab")
        self.assertEqual(fields[2], "2")
        self.assertIn("\u00b7", fields[3])         # that is all it displays


class SubjectTests(unittest.TestCase):
    """The session name can only come from the pane title."""

    def setUp(self) -> None:
        self.codex = detect.RuleSet.load(scan.RULES_DIR).match_bin("codex")

    def subject(self, title: str, cwd: str = "/home/lijun/Repositories/personal/homelab") -> str:
        return detect.subject(self.codex, title, cwd)

    def test_thread_title_from_the_pane_title(self) -> None:
        self.assertEqual(self.subject("\u283c Organize AI agents in tmux"), "Organize AI agents in tmux")

    def test_the_name_is_found_at_either_end(self) -> None:
        self.assertEqual(
            self.subject("\u283c Organize AI agents in tmux | homelab"),
            "Organize AI agents in tmux",
        )
        self.assertEqual(
            self.subject("\u283c homelab | Organize AI agents in tmux"),
            "Organize AI agents in tmux",
        )

    def test_action_required_prefix_is_removed(self) -> None:
        self.assertEqual(self.subject("Action Required \u283c Fix the parser"), "Fix the parser")
        self.assertEqual(self.subject("\u283c Action Required Fix the parser"), "Fix the parser")

    def test_directory_echo_is_not_a_session_name(self) -> None:
        # The default title is just the spinner plus the directory.
        self.assertEqual(self.subject("\u283c homelab"), "")
        self.assertEqual(self.subject("homelab"), "")
        self.assertEqual(self.subject("\u283c"), "")

    def test_agent_name_is_not_a_session_name(self) -> None:
        self.assertEqual(self.subject("\u283c codex", "/tmp/x"), "")
        # OpenCode titles its pane with just its own name.
        opencode = detect.RuleSet.load(scan.RULES_DIR).match_bin("opencode")
        self.assertEqual(detect.subject(opencode, "OpenCode", "/tmp/x"), "")

    def test_an_unnamed_thread_identifier_is_not_a_session_name(self) -> None:
        # Codex prints the thread id until the session has a title.
        self.assertEqual(
            self.subject("\u283c homelab | 01a12ca5-57a4-7780-a398-5bb03e1b62bb"), ""
        )


class CliTests(unittest.TestCase):
    """The CLI is the installed entry point, so its wiring is worth a test."""

    def setUp(self) -> None:
        from clj_agents import cli

        self.cli = cli
        self.parser = cli.build_parser()

    def test_a_subcommand_is_required(self) -> None:
        with self.assertRaises(SystemExit):
            self.parser.parse_args([])

    def test_scan_defaults_to_tsv_and_the_packaged_rules(self) -> None:
        args = self.parser.parse_args(["scan"])
        self.assertEqual(args.format, "tsv")
        self.assertEqual(args.rules, scan.RULES_DIR)

    def test_subcommands_dispatch_to_their_modules(self) -> None:
        self.assertIs(self.parser.parse_args(["scan"]).run, scan.run)
        self.assertIs(self.parser.parse_args(["popup"]).run, popup.run)

    def test_version(self) -> None:
        import contextlib
        import io

        from clj_agents import __version__

        out = io.StringIO()
        with contextlib.redirect_stdout(out), self.assertRaises(SystemExit):
            self.parser.parse_args(["--version"])
        self.assertIn(__version__, out.getvalue())

    def test_scan_exits_cleanly_without_a_tmux_server(self) -> None:
        import contextlib
        import io
        import unittest.mock

        out = io.StringIO()
        with unittest.mock.patch.object(scan, "list_panes", lambda: []), contextlib.redirect_stdout(out):
            self.assertEqual(self.cli.main(["scan", "--format", "json"]), 0)
        self.assertEqual(out.getvalue().strip(), "[]")


if __name__ == "__main__":
    unittest.main()

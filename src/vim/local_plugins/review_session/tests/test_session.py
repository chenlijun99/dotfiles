import base64
import json
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "python"))
from review_session.core import Error, execute


def append(session, thread, n):
    execute(session, "reply", {"thread": thread, "body": str(n)})


class SessionTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.session = str(self.root / "session")
        self.git("init", "-q")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.com")
        (self.repo / "a").write_text("one\ntwo\n")
        self.git("add", ".")
        self.git("commit", "-qm", "base")
        self.base = self.git("rev-parse", "HEAD").strip()
        (self.repo / "a").write_text("one\nchanged\n")
        self.git("commit", "-qam", "head")
        self.head = self.git("rev-parse", "HEAD").strip()
        self.call("init", repo=str(self.repo))

    def tearDown(self):
        self.temp.cleanup()

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.repo), *args], text=True)

    def call(self, op, **args):
        return execute(self.session, op, args)

    def view(self, old=None, new=None, path="a"):
        return {"repo": str(self.repo), "old": old or self.base, "new": new or self.head, "path": path}

    def create(self, **args):
        return self.call("create", view=args.pop("view", self.view()), body=args.pop("body", "Question"), scope=args.pop("scope", "range"), start=args.pop("start", 2), **args)

    def test_navigation_does_not_write_or_enroll(self):
        db = Path(self.session) / "session.sqlite3"
        before = db.read_bytes(), db.stat().st_mtime_ns, sorted(Path(self.session).iterdir())
        for view in (self.view(), self.view(self.head, "INDEX"), self.view("INDEX", "WORKTREE")):
            self.call("view", view=view)
            self.call("threads", view=view)
        self.call("queue", role="agent")
        self.assertEqual(before, (db.read_bytes(), db.stat().st_mtime_ns, sorted(Path(self.session).iterdir())))
        connection = sqlite3.connect(db)
        state = json.loads(connection.execute("select data from session").fetchone()[0])
        connection.close()
        self.assertEqual(state["reviewed"], {})
        self.assertEqual(state["threads"], {})
        self.assertNotIn("comparisons", state)

    def test_exact_pair_and_another_revision_hint(self):
        first = self.view()
        self.assertEqual(self.call("view", view=first)["files"][0]["reviewed"], "pending")
        self.call("mark", view=first)
        self.assertEqual(self.call("view", view=first)["files"][0]["reviewed"], "reviewed")
        (self.repo / "unrelated").write_text("other")
        self.git("add", ".")
        self.git("commit", "-qm", "unrelated")
        self.assertEqual(self.call("view", view=self.view(new="HEAD"))["files"][0]["reviewed"], "reviewed")
        (self.repo / "a").write_text("third version\n")
        self.git("commit", "-qam", "third")
        second = self.view(self.head, "HEAD")
        self.assertEqual(self.call("view", view=second)["files"][0]["reviewed"], "another")
        self.call("mark", view=second)
        self.call("mark", view=second, value="pending")
        self.assertEqual(self.call("view", view=second)["files"][0]["reviewed"], "another")
        self.assertEqual(self.call("view", view=first)["files"][0]["reviewed"], "reviewed")

    def test_capture_on_action_and_exact_mutable_index_pair(self):
        (self.repo / "a").write_text("staged\n")
        self.git("add", "a")
        (self.repo / "a").write_text("unstaged\n")
        staged, unstaged = self.view(self.head, "INDEX"), self.view("INDEX", "WORKTREE")
        self.assertNotEqual(self.call("view", view=staged)["files"][0]["fingerprint"], self.call("view", view=unstaged)["files"][0]["fingerprint"])
        thread = self.create(view=unstaged, start=1)
        self.assertEqual(self.call("source", thread=thread["id"], side="old")["text"], "staged\n")
        self.assertEqual(self.call("source", thread=thread["id"], side="new")["text"], "unstaged\n")
        self.call("mark", view=unstaged)
        self.git("add", "a")
        self.assertEqual(self.call("view", view=unstaged)["files"][0]["reviewed"], "another")
        self.assertEqual(self.call("source", thread=thread["id"], side="old")["text"], "staged\n")
        self.assertTrue(self.call("show", thread=thread["id"])["thread"]["outdated"])

    def test_visibility_exact_revisions_and_edit_revert(self):
        t = self.create()
        self.assertEqual(self.call("threads", role="agent"), [])
        with self.assertRaises(Error):
            self.call("show", thread=t["id"], role="agent")
        self.call("share", thread=t["id"])
        m = t["messages"][0]
        changed = self.call("edit", thread=t["id"], message=m["id"], revision=m["revision"], body="New")
        self.call("reply", thread=t["id"], role="agent", body="Old response", ack=[m["revision"]])
        self.assertEqual(self.call("queue", role="agent")[0]["pending"][0]["body"], "New")
        rev = changed["messages"][0]["revision"]
        self.call("reply", thread=t["id"], role="agent", body="Done", ack=[rev])
        self.assertEqual(self.call("queue", role="agent"), [])
        self.call("edit", thread=t["id"], message=m["id"], revision=rev, body="Question")
        self.assertEqual(len(self.call("queue", role="agent")), 1)
        with self.assertRaises(Error):
            self.call("edit", thread=t["id"], message=m["id"], revision=rev, body="Lost write")
        agent = self.create(role="agent")
        self.assertTrue(agent["shared"])

    def test_live_new_input_without_intervening_refresh(self):
        for op in ("reply", "edit"):
            with self.subTest(op=op):
                (self.repo / "a").write_text("original worktree\n")
                t = self.create(view=self.view("INDEX", "WORKTREE"), start=1)
                self.call("share", thread=t["id"])
                (self.repo / "a").write_text("changed by agent\n")
                self.assertEqual([row for row in self.call("queue", role="agent") if row["thread"] == t["id"]], [])
                args = {"thread": t["id"], "body": "Deliberate new input"}
                if op == "edit":
                    args.update(message=t["messages"][0]["id"], revision=t["messages"][0]["revision"])
                self.call(op, **args)
                row = next(row for row in self.call("queue", role="agent") if row["thread"] == t["id"])
                self.assertTrue(row["outdated"])
                self.assertEqual([m["body"] for m in row["pending"]], ["Deliberate new input"])

    def test_stale_composition_guard(self):
        (self.repo / "a").write_text("selected\n")
        view = self.view("INDEX", "WORKTREE")
        fingerprint = self.call("view", view=view)["files"][0]["fingerprint"]
        (self.repo / "a").write_text("concurrent\n")
        with self.assertRaisesRegex(Error, "source changed"):
            self.create(view=view, start=1, expected_fingerprint=fingerprint)
        self.assertEqual(self.call("threads"), [])

    def test_bulk_targets_only_and_nontext_no_source_writes(self):
        (self.repo / "a").unlink()
        (self.repo / "binary").write_bytes(b"a\0b")
        (self.repo / "link").symlink_to("/missing")
        view = {"repo": str(self.repo), "old": "INDEX", "new": "WORKTREE"}
        status = self.call("view", view=view)
        self.assertEqual(status["total"], 3)
        self.call("mark", view=view)
        self.assertEqual(self.call("view", view=view)["reviewed"], 3)
        (self.repo / "later").write_text("new pending")
        self.assertEqual(self.call("view", view=view)["reviewed"], 3)
        self.assertEqual((self.repo / "binary").read_bytes(), b"a\0b")
        with self.assertRaises(Error):
            self.create(view=self.view("INDEX", "WORKTREE", "binary"), start=1)
        self.call("mark", view={"repo": str(self.repo), "files": [{"old": "INDEX", "new": "WORKTREE", "old_path": "a", "new_path": None}]}, value="pending")
        self.assertEqual(self.call("view", view=view)["reviewed"], 2)

    def test_relevant_threads_and_original_reanchor(self):
        original = self.create()
        (self.repo / "a").write_text("third\n")
        self.git("commit", "-qam", "third")
        view = self.view(self.head, "HEAD")
        threads = self.call("threads", view=view)
        self.assertEqual(threads[0]["id"], original["id"])
        self.assertTrue(threads[0]["other_revision"])
        self.call("reanchor", thread=original["id"], view=view, scope="range", start=1)
        shown = self.call("show", thread=original["id"])["thread"]
        self.assertEqual(shown["anchor"], original["anchor"])
        self.assertNotEqual(shown["publication_anchor"]["fingerprint"], original["anchor"]["fingerprint"])
        self.assertEqual(self.call("source", thread=original["id"])["text"], "one\nchanged\n")

    def test_concurrency_rollback_and_session_independence(self):
        t = self.create()
        with ProcessPoolExecutor(max_workers=4) as pool:
            list(pool.map(append, [self.session] * 12, [t["id"]] * 12, range(12)))
        self.assertEqual(len(self.call("show", thread=t["id"])["thread"]["messages"]), 13)
        with self.assertRaises(Error):
            self.call("reply", thread=t["id"], body="")
        self.assertEqual(len(self.call("show", thread=t["id"])["thread"]["messages"]), 13)
        with self.assertRaises(sqlite3.OperationalError), patch("review_session.core.sqlite3.connect", side_effect=sqlite3.OperationalError("disk full")):
            self.call("resolve", thread=t["id"])
        self.assertFalse(self.call("show", thread=t["id"])["thread"]["resolved"])
        other = str(self.root / "other")
        execute(other, "init", {"repo": str(self.repo)})
        self.assertEqual(execute(other, "threads", {}), [])

    def test_snapshots_survive_repository_loss(self):
        t = self.create()
        self.repo.rename(self.root / "gone")
        self.assertEqual(self.call("source", thread=t["id"])["text"], "one\nchanged\n")

    def test_publication_selection_coordinates_receipts_and_summary(self):
        t = self.create(side="old")
        m = t["messages"][0]
        self.call("draft", thread=t["id"], message=m["id"], revision=m["revision"])
        self.call("reply", thread=t["id"], body="Do not publish this reply")
        remote = []
        def api(endpoint, payload=None):
            if payload:
                remote.append({"id": len(remote) + 1, "html_url": "https://example/comment", "body": payload["body"]})
                return remote[-1]
            if "/compare/" in endpoint:
                return {"merge_base_commit": {"sha": self.base}}
            if "/files?" in endpoint:
                return [{"filename": "a", "patch": "@@ -1,2 +1,2 @@\n one\n-two\n+changed"}]
            if "?" in endpoint:
                return remote
            return {"state": "open", "head": {"sha": self.head}, "base": {"sha": self.base}}
        with patch("review_session.publish.api", side_effect=api):
            preview = self.call("preview", thread=t["id"], destination="owner/repo#1")
            self.assertEqual(preview["payload"]["side"], "LEFT")
            self.assertTrue(preview["payload"]["body"].startswith("Question"))
            self.assertEqual(remote, [])
            with self.assertRaisesRegex(Error, "preview again"):
                self.call("publish", thread=t["id"], destination="owner/repo#1", expected_preview="stale")
            self.call("publish", thread=t["id"], destination="owner/repo#1")
            self.call("publish", thread=t["id"], destination="owner/repo#1")
            self.assertEqual(len(remote), 1)
            db = sqlite3.connect(Path(self.session) / "session.sqlite3")
            state = json.loads(db.execute("select data from session").fetchone()[0])
            state["publications"] = {}
            db.execute("update session set data=?", (json.dumps(state),))
            db.commit()
            db.close()
            self.call("publish", thread=t["id"], destination="owner/repo#1")
            self.assertEqual(len(remote), 1)
            with self.assertRaisesRegex(Error, "selected draft changed"):
                self.call("publish", thread=t["id"], destination="owner/repo#1", revision="stale")
            # A historical/intermediate head is incompatible inline, but explicit summary is valid.
            self.head = "different-current-head"
            with self.assertRaisesRegex(Error, "PR head"):
                self.call("preview", thread=t["id"], destination="owner/repo#1")
            summary = self.call("publish", thread=t["id"], destination="owner/repo#1", summary=True)
            self.assertIn("/issues/1/comments", summary["endpoint"])
            self.assertNotIn("line", summary["payload"])
            self.assertEqual(len(remote), 2)

    def test_publication_rejects_diverged_old_side(self):
        t = self.create(side="old")
        m = t["messages"][0]
        self.call("draft", thread=t["id"], message=m["id"], revision=m["revision"])
        def api(endpoint):
            return {"merge_base_commit": {"sha": "different-merge-base"}} if "/compare/" in endpoint else {"state": "open", "head": {"sha": self.head}, "base": {"sha": self.base}}
        with patch("review_session.publish.api", side_effect=api), self.assertRaisesRegex(Error, "merge base"):
            self.call("preview", thread=t["id"], destination="owner/repo#1")

    def test_reviewed_history_and_missing_object_fallback(self):
        self.call("mark", view=self.view())
        pair = self.call("history", view=self.view())[0]
        self.assertEqual((pair["old_ref"], pair["new_ref"]), (self.base, self.head))
        self.assertTrue(self.call("context", fingerprint=pair["fingerprint"])["available"])
        self.repo.rename(self.root / "gone")
        self.assertFalse(self.call("context", fingerprint=pair["fingerprint"])["available"])
        self.assertEqual(self.call("source", fingerprint=pair["fingerprint"], side="old")["text"], "one\ntwo\n")
        note = self.call("create", scope="review", body="Workspace note without source")
        self.assertEqual(note["anchor"]["old_ref"], "SESSION")

    def test_actual_index_stages(self):
        one = self.git("rev-parse", self.base + ":a").strip()
        two = self.git("rev-parse", self.head + ":a").strip()
        self.git("update-index", "--force-remove", "a")
        subprocess.run(["git", "-C", str(self.repo), "update-index", "--index-info"], input=f"100644 {one} 1\ta\n100644 {two} 2\ta\n100644 {one} 3\ta\n", text=True, check=True)
        t = self.create(view=self.view("INDEX:1", "INDEX:2"), start=2)
        self.assertEqual(self.call("source", thread=t["id"], side="old")["text"], "one\ntwo\n")
        self.assertEqual(self.call("source", thread=t["id"], side="new")["text"], "one\nchanged\n")

    def test_added_pair_is_identical_across_cli_and_viewer(self):
        (self.repo / "added").write_text("added\n")
        direct = self.view(self.head, "WORKTREE", "added")
        viewer = {"repo": str(self.repo), "files": [{"old": self.head, "new": "WORKTREE", "old_path": None, "new_path": "added"}]}
        self.call("mark", view=direct)
        self.assertEqual(self.call("view", view=viewer)["files"][0]["reviewed"], "reviewed")
        with self.assertRaises(Error):
            self.create(start=0)

    def test_absent_mutable_sides_are_reprobed_without_changing_originals(self):
        for action in ("recreate-deleted", "stage-added"):
            with self.subTest(action=action):
                path = "a" if action == "recreate-deleted" else "added"
                if action == "recreate-deleted":
                    (self.repo / path).unlink()
                else:
                    (self.repo / path).write_text("added source\n")
                view = self.view("INDEX", "WORKTREE", path)
                file = self.call("view", view=view)["files"][0]
                t = self.call("create", view=file["view"], scope="file", body="Immutable absence", expected_fingerprint=file["fingerprint"])
                original = t["anchor"]
                self.assertTrue(self.call("context", thread=t["id"])["available"])
                if action == "recreate-deleted":
                    self.assertIsNone(original["new"])
                    (self.repo / path).write_text("recreated source\n")
                else:
                    self.assertIsNone(original["old"])
                    self.git("add", path)
                self.assertFalse(self.call("context", thread=t["id"])["available"])
                shown = self.call("show", thread=t["id"])["thread"]
                self.assertTrue(shown["outdated"])
                self.assertEqual(shown["anchor"], original)
                with self.assertRaisesRegex(Error, "source changed"):
                    self.call("create", view=file["view"], scope="file", body="Stale composition", expected_fingerprint=file["fingerprint"])
                with self.assertRaisesRegex(Error, "source changed"):
                    self.call("mark", view=file["view"], expected_fingerprint=file["fingerprint"])
                self.assertEqual(len(self.call("threads")), 1 if action == "recreate-deleted" else 2)

    def test_publication_reanchor_does_not_change_discussion_or_attention(self):
        t = self.create()
        self.call("share", thread=t["id"])
        self.call("resolve", thread=t["id"])
        m = t["messages"][0]
        self.call("draft", thread=t["id"], message=m["id"], revision=m["revision"])
        before = self.call("show", thread=t["id"])["thread"]
        queue = self.call("queue", role="agent")
        (self.repo / "a").write_text("new publication location\n")
        self.git("commit", "-qam", "later")
        self.call("reanchor", thread=t["id"], view=self.view(self.head, "HEAD"), scope="range", start=1)
        after = self.call("show", thread=t["id"])["thread"]
        self.assertEqual(self.call("queue", role="agent"), queue)
        for field in ("anchor", "shared", "resolved", "messages", "draft", "acked", "attention_on_outdated", "outdated"):
            self.assertEqual(after[field], before[field], field)
        self.assertFalse(after["outdated"])
        self.assertEqual(self.call("source", thread=t["id"])["text"], "one\nchanged\n")

    def test_display_observations_reject_stale_working_and_index_sources(self):
        for ref in ("WORKTREE", "INDEX:0"):
            with self.subTest(ref=ref):
                if ref == "WORKTREE":
                    (self.repo / "a").write_text("saved working\n")
                    lines = ["saved working"]
                    view = self.view("INDEX", "WORKTREE")
                else:
                    lines = ["one", "changed"]
                    view = self.view(self.base, "INDEX")
                view["observations"] = [{"ref": ref, "path": "a", "lines": lines, "fileformat": "unix", "endofline": True}]
                selected = self.call("view", view=view)["files"][0]
                (self.repo / "a").write_text("external source\n")
                if ref.startswith("INDEX:"):
                    self.git("add", "a")
                db = Path(self.session) / "session.sqlite3"
                before = db.read_bytes()
                for operation in ("view", "create", "mark"):
                    with self.assertRaisesRegex(Error, "reload.*reselect"):
                        self.call(operation, view=view, scope="range", start=1, body="Different displayed context")
                    self.assertEqual(db.read_bytes(), before)
                # A delayed descriptor carries the same original display evidence.
                selected["view"]["observations"] = view["observations"]
                with self.assertRaisesRegex(Error, "reload.*reselect"):
                    self.call("create", view=selected["view"], scope="range", start=1, body="Delayed", expected_fingerprint=selected["fingerprint"])

    def test_matching_display_formats_preserve_saved_bytes(self):
        cases = [(b"without newline", ["without newline"], "unix", False),
                 (b"one\r\ntwo\r\n", ["one", "two"], "dos", True),
                 (b"one\r\ntwo", ["one", "two"], "dos", False),
                 (b"", [""], "unix", True)]
        for source, lines, format_, eol in cases:
            with self.subTest(source=source):
                (self.repo / "format").write_bytes(source)
                view = self.view("INDEX", "WORKTREE", "format")
                view["observations"] = [{"ref": "WORKTREE", "path": "format", "lines": lines, "fileformat": format_, "endofline": eol}]
                t = self.call("create", view=view, scope="file", body="Matching source")
                self.assertEqual(self.call("source", thread=t["id"])["blob"]["data"], base64.b64encode(source).decode())
        # Git line viewers normalize CRLF and do not expose the final-newline bit.
        (self.repo / "format").write_bytes(b"one\r\ntwo")
        self.git("add", "format")
        view = self.view(self.base, "INDEX", "format")
        view["observations"] = [{"ref": "INDEX:0", "path": "format", "lines": ["one", "two"], "layout": "lines"}]
        self.call("mark", view=view)

    def test_agent_skill_cli_workflow(self):
        script = Path(__file__).resolve().parents[1] / "bin/review-session"
        def command(*args):
            result = subprocess.run([sys.executable, str(script), "--session", self.session, "--role", "agent", *args], capture_output=True, check=True)
            return json.loads(result.stdout)
        finding = self.root / "finding.md"
        finding.write_text("Evidence: original old-side line two. Consequence: behavior regression. Severity: P2.")
        created = command("create", "--repo", str(self.repo), "--old", self.base, "--new", self.head, "--path", "a", "--side", "old", "--start", "2", "--body-file", str(finding))
        self.assertTrue(created["shared"])
        self.assertEqual(command("source", "--thread", created["id"], "--side", "old")["text"], "one\ntwo\n")
        self.call("reply", thread=created["id"], body="Please inspect")
        queued = command("queue")[0]["pending"][0]
        response = self.root / "response.md"
        response.write_text("Investigated and confirmed against original source.")
        command("reply", "--thread", created["id"], "--ack", queued["revision"], "--body-file", str(response))
        self.assertEqual(command("queue"), [])
        coverage = self.root / "coverage.md"
        coverage.write_text(f"Target: {self.head}\nBase: {self.base}\nIntent: preserve behavior\nGuidance: AGENTS.md\nCompleted: original-source check\nUnverified: live deployment")
        command("coverage", "--target", "fixture-review", "--body-file", str(coverage))
        records = command("coverage")
        self.assertEqual(len(records), 1)
        self.assertIn(self.base, records[0]["body"])
        self.assertEqual(command("show", "--thread", created["id"])["thread"]["anchor"]["start"], 2)

    def test_cli_request_and_readonly_view(self):
        script = Path(__file__).resolve().parents[1] / "bin/review-session"
        result = subprocess.run([sys.executable, str(script), "--session", self.session, "view", "--request-file", "-"], input=json.dumps({"view": self.view()}).encode(), capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["files"][0]["reviewed"], "pending")


if __name__ == "__main__":
    unittest.main()

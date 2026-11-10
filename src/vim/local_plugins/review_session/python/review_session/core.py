"""Transactional review sessions, with no editor or third-party dependencies."""
from __future__ import annotations

import base64
import hashlib
import io
import json
import os
import sqlite3
import subprocess
import uuid
from collections.abc import Generator
from contextlib import contextmanager
from pathlib import Path
from typing import Any, cast


class Error(Exception):
    """A safe, user-facing request failure."""


def uid() -> str:
    return uuid.uuid4().hex


def require(condition: Any, message: str) -> None:
    if not condition:
        raise Error(message)


def run(args: list[str], cwd: str | None = None, data: Any = None) -> bytes:
    result = subprocess.run(args, check=False, cwd=cwd, input=data if isinstance(data, bytes) else None if data is None else json.dumps(data).encode(), capture_output=True)
    if result.returncode:
        raise Error(result.stderr.decode(errors="replace").strip() or f"{args[0]} failed")
    return result.stdout


def git(repo: str, *args: str) -> bytes:
    return run(["git", "-C", repo, *args])


def revision(repo: str, value: str) -> str:
    require(not value.startswith("-"), "invalid revision")
    return git(repo, "rev-parse", "--verify", value + "^{commit}").decode().strip()


def digest(value: Any) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def text(blob: dict[str, str] | None) -> str:
    if blob is None:
        return ""
    return base64.b64decode(blob["data"]).decode("utf-8", errors="replace")


def tree(repo: str, rev: str) -> dict[str, dict[str, str]]:
    entries = []
    for entry in git(repo, "ls-tree", "-rz", rev).split(b"\0"):
        if entry:
            meta, name = entry.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            entries.append((mode, kind, oid, os.fsdecode(name)))
    blobs = read_blobs(repo, {oid for _, kind, oid, _ in entries if kind == "blob"})
    return {path: {"mode": mode, "data": base64.b64encode(blobs[oid] if kind == "blob" else oid.encode()).decode()}
            for mode, kind, oid, path in entries}


def read_blobs(repo: str, ids: set[str]) -> dict[str, bytes]:
    ordered = sorted(ids)
    blobs = {}
    if ordered:
        stream = io.BytesIO(run(["git", "-C", repo, "cat-file", "--batch"], data=("\n".join(ordered) + "\n").encode()))
        for oid in ordered:
            header = stream.readline().decode().split()
            require(len(header) == 3 and header[1] == "blob", "cannot read source snapshot")
            blobs[oid] = stream.read(int(header[2]))
            stream.read(1)
    return blobs


@contextmanager
def store(folder: str, create: bool = False, readonly: bool = False) -> Generator[dict, None, None]:
    path = Path(folder).expanduser().resolve()
    if create:
        path.mkdir(parents=True, exist_ok=True)
    require(path.is_dir() and (create or (path / "session.sqlite3").is_file()), "session does not exist")
    database = path / "session.sqlite3"
    connection = sqlite3.connect(database.as_uri() + "?mode=ro" if readonly else database, timeout=30, uri=readonly)
    try:
        if not readonly:
            connection.execute("PRAGMA synchronous=FULL")
            connection.execute("BEGIN IMMEDIATE")
            connection.execute("CREATE TABLE IF NOT EXISTS session (id INTEGER PRIMARY KEY CHECK(id=1), data TEXT NOT NULL)")
        row = connection.execute("SELECT data FROM session WHERE id=1").fetchone()
        state = json.loads(row[0]) if row else {}
        yield state
        if not readonly:
            connection.execute("INSERT OR REPLACE INTO session VALUES (1, ?)", (json.dumps(state),))
            connection.commit()
    except BaseException:
        if not readonly:
            connection.rollback()
        raise
    finally:
        connection.close()


def body(args: dict) -> str:
    value = args.get("body", "")
    require(isinstance(value, str) and bool(value.strip()), "message must not be empty")
    return value


def thread_for(state: dict, args: dict) -> dict:
    require(args.get("thread") in state["threads"], "unknown thread")
    thread = state["threads"][args["thread"]]
    require(args.get("role", "human") != "agent" or thread["shared"], "thread is human-only")
    return thread


def message_for(thread: dict, ident: str) -> dict:
    found = next((m for m in thread["messages"] if m["id"] == ident), None)
    require(found is not None, "unknown message")
    assert found is not None
    return found


def outdated(thread: dict) -> bool:
    from .targets import current
    anchor = thread["anchor"]
    return anchor["scope"] != "review" and not current(anchor)


def pending(thread: dict) -> list[dict]:
    if not thread["shared"]:
        return []
    stale = outdated(thread)
    return [{"id": m["id"], "revision": m["revision"], "body": m["body"]}
            for m in thread["messages"] if m["role"] == "human" and m["revision"] not in thread["acked"]
            and (not stale or m["revision"] in thread["attention_on_outdated"])]


def public_thread(thread: dict, pairs: list[dict] | None = None) -> dict:
    from .targets import same_file
    result = dict(thread, outdated=outdated(thread))
    if pairs is not None and thread["anchor"]["scope"] != "review":
        matching = [p for p in pairs if same_file(p, thread["anchor"])]
        result["other_revision"] = bool(matching) and not any(p["fingerprint"] == thread["anchor"]["fingerprint"] for p in matching)
    return result


def render(thread: dict) -> str:
    anchor = thread["anchor"]
    lines = [f'# Thread {thread["id"]}', "", f'{"shared" if thread["shared"] else "human-only"} | {"resolved" if thread["resolved"] else "open"} | {"outdated" if thread["outdated"] else "original context"}', "",
             f'Anchor: {anchor["repo"]} {anchor.get("path", "review")} {anchor.get("side", "")} {anchor.get("start", "")}:{anchor.get("end", "")}',
             f'Versions: {anchor["old_ref"]} → {anchor["new_ref"]}', ""]
    for message in thread["messages"]:
        lines += [f'## {message["role"]} {message["id"]} (revision {message["revision"]})', "", message["body"], ""]
    return "\n".join(lines)


def view_for(state: dict, args: dict) -> list[dict]:
    from .targets import capture
    view = args.get("view") or {k: args[k] for k in ("repo", "old", "new", "path", "old_path", "new_path", "files") if k in args}
    return capture(view, state.get("repo"))


def anchor_for(state: dict, args: dict) -> dict:
    from .targets import selector
    view = args.get("view", args)
    require(isinstance(view, dict), "view must be an object")
    scope = args.get("scope", "range" if "start" in args else "file" if args.get("path") or view.get("path") or view.get("old_path") or view.get("new_path") or view.get("files") else "review")
    require(scope in ("review", "file", "range"), "invalid scope")
    if scope == "review":
        view = args.get("view", args)
        repo = str(Path(view.get("repo") or state.get("repo") or ".").resolve())
        return {"scope": scope, "repo": repo, "old_ref": selector(repo, view["old"]) if "old" in view else "SESSION", "new_ref": selector(repo, view["new"]) if "new" in view else "SESSION"}
    pairs = view_for(state, args)
    require(len(pairs) == 1, "thread needs exactly one file pair")
    pair = pairs[0]
    require(not args.get("expected_fingerprint") or args["expected_fingerprint"] == pair["fingerprint"], "source changed; reopen composition at the intended source")
    side = args.get("side", "new")
    require(side in ("old", "new"), "invalid side")
    anchor = dict(pair, scope=scope, side=side)
    if scope == "range":
        start, end = args["start"], args.get("end") or args["start"]
        require(isinstance(start, int) and isinstance(end, int) and 1 <= start <= end <= len(text(pair[side]).splitlines()), "invalid source range")
        require(pair[side] is not None and b"\0" not in base64.b64decode(pair[side]["data"]), "binary source cannot have a line anchor")
        anchor.update(start=start, end=end)
    return anchor


def execute(folder: str, operation: str, args: dict) -> Any:
    from .targets import descriptor, same_file
    require(args.get("role", "human") in ("human", "agent"), "invalid role")
    readonly = operation in ("view", "status", "threads", "queue", "show", "source", "context", "history", "preview") or (operation == "coverage" and not args.get("body"))
    with store(folder, create=operation == "init", readonly=readonly) as state:
        if operation == "init":
            require(not state, "session already initialized")
            repo = git(str(Path(args.get("repo", ".")).resolve()), "rev-parse", "--show-toplevel").decode().strip()
            state.update(version=2, repo=repo, threads={}, coverage=[], reviewed={}, publications={})
            return {"repo": repo, "session": str(Path(folder).resolve())}
        require(state.get("version") == 2, "unsupported session format (expected viewer-driven format 2)")
        if operation in ("view", "status"):
            pairs = view_for(state, args)
            files = []
            for pair in pairs:
                status = "reviewed" if pair["fingerprint"] in state["reviewed"] else "another" if any(same_file(pair, saved) for saved in state["reviewed"].values()) else "pending"
                files.append({k: v for k, v in pair.items() if k not in ("old", "new")} | {"reviewed": status, "view": descriptor(pair)})
            return {"files": files, "reviewed": len({f["fingerprint"] for f in files if f["reviewed"] == "reviewed"}), "total": len({f["fingerprint"] for f in files})}
        if operation == "mark":
            pairs = list({p["fingerprint"]: p for p in view_for(state, args)}.values())
            require(pairs, "no file pairs in current view")
            expected = args.get("expected_fingerprints") or ([args["expected_fingerprint"]] if args.get("expected_fingerprint") else None)
            require(expected is None or sorted(set(expected)) == sorted(p["fingerprint"] for p in pairs), "source changed; refresh before marking")
            value = args.get("value", "toggle")
            require(value in ("toggle", "reviewed", "pending"), "invalid mark value")
            mark = not all(p["fingerprint"] in state["reviewed"] for p in pairs) if value == "toggle" else value == "reviewed"
            for pair in pairs:
                if mark:
                    state["reviewed"][pair["fingerprint"]] = pair
                else:
                    state["reviewed"].pop(pair["fingerprint"], None)
            return {"reviewed": mark, "fingerprints": [p["fingerprint"] for p in pairs]}
        if operation == "history":
            pairs = view_for(state, args) if args.get("view") or args.get("path") else None
            return [p for p in state["reviewed"].values() if pairs is None or any(same_file(p, selected) for selected in pairs)]
        if operation == "create":
            anchor = anchor_for(state, args)
            ident = uid()
            thread: dict = {"id": ident, "anchor": anchor, "shared": args.get("role") == "agent", "resolved": False,
                      "acked": [], "attention_on_outdated": [], "draft": None,
                      "messages": [{"id": uid(), "revision": uid(), "role": args.get("role", "human"), "body": body(args)}]}
            state["threads"][ident] = thread
            return public_thread(thread)
        if operation in ("threads", "queue"):
            threads = [t for t in state["threads"].values() if args.get("role", "human") != "agent" or t["shared"]]
            pairs = view_for(state, args) if args.get("view") or args.get("old") or args.get("path") else None
            if pairs is not None:
                threads = [t for t in threads if t["anchor"]["scope"] == "review" or any(same_file(t["anchor"], p) for p in pairs)]
            if operation == "queue":
                return [{"thread": t["id"], "outdated": outdated(t), "pending": pending(t)} for t in threads if pending(t)]
            return [public_thread(t, pairs) for t in threads]
        if operation == "coverage":
            if args.get("body"):
                state["coverage"].append({"target": args.get("target", "session"), "role": args.get("role", "human"), "body": body(args), "id": uid()})
            return state["coverage"]
        if operation in ("context", "source") and args.get("fingerprint"):
            require(args["fingerprint"] in state["reviewed"], "unknown reviewed pair")
            thread = cast(dict, {"anchor": dict(state["reviewed"][args["fingerprint"]], scope="file", side="new")})
        else:
            thread = thread_for(state, args)
        if operation == "show":
            receipts = [r for r in state["publications"].values() if r["thread"] == thread["id"]]
            markdown = render(public_thread(thread))
            if receipts:
                markdown += "\n## Publications\n\n" + "\n".join(f'- {r["destination"]}: {r["url"]}' for r in receipts)
            return {"thread": public_thread(thread), "markdown": markdown, "receipts": receipts}
        if operation == "context":
            from .targets import capture
            anchor = thread["anchor"]
            available = False
            if anchor["scope"] != "review":
                try:
                    view = descriptor(anchor)
                    view["observations"] = args.get("observations", [])
                    available = capture(view)[0]["fingerprint"] == anchor["fingerprint"]
                except (Error, OSError, ValueError):
                    pass
            return {"anchor": anchor, "available": available, "view": descriptor(anchor) if anchor["scope"] != "review" else None}
        if operation == "source":
            anchor = thread["anchor"]
            side = args.get("side", anchor.get("side", "new"))
            require(side in ("old", "new") and anchor["scope"] != "review", "no source at this anchor")
            return {"path": anchor.get(side + "_path") or anchor["path"], "side": side, "text": text(anchor[side]), "blob": anchor[side], "start": anchor.get("start", 1)}
        if operation == "reply":
            acknowledgements = args.get("ack", [])
            require(args.get("role", "human") == "agent" or not acknowledgements, "only agent replies acknowledge human input")
            revisions = {m["revision"] for m in thread["messages"] if m["role"] == "human"}
            require(isinstance(acknowledgements, list) and all(isinstance(a, str) for a in acknowledgements), "invalid acknowledgements")
            thread["acked"] += [a for a in acknowledgements if a in revisions and a not in thread["acked"]]
            message = {"id": uid(), "revision": uid(), "role": args.get("role", "human"), "body": body(args)}
            if message["role"] == "human" and outdated(thread):
                thread["attention_on_outdated"].append(message["revision"])
            thread["messages"].append(message)
        elif operation == "edit":
            message = message_for(thread, args["message"])
            require(message["role"] == args.get("role", "human"), "cannot edit the other role's message")
            require(message["revision"] == args["revision"], "message changed; reload before editing")
            message.update(body=body(args), revision=uid())
            if message["role"] == "human" and outdated(thread):
                thread["attention_on_outdated"].append(message["revision"])
        elif operation == "share":
            require(args.get("role", "human") == "human", "only human may change sharing")
            require(args.get("value", "shared") in ("shared", "human-only"), "invalid visibility")
            thread["shared"] = args.get("value", "shared") == "shared"
        elif operation == "resolve":
            require(args.get("value", "resolved") in ("resolved", "open"), "invalid resolution")
            thread["resolved"] = args.get("value", "resolved") == "resolved"
        elif operation == "reanchor":
            require(args.get("role", "human") == "human", "only human may select a new publication anchor")
            thread["publication_anchor"] = anchor_for(state, args)
        elif operation == "draft":
            require(args.get("role", "human") == "human", "only human selects publication drafts")
            message = message_for(thread, args["message"])
            require(message["revision"] == args["revision"], "message changed; reload before selecting")
            thread["draft"] = {"message": message["id"], "revision": message["revision"], "body": message["body"]}
        elif operation in ("preview", "publish"):
            from .publish import publish
            return publish(state, thread, args, operation == "publish")
        else:
            raise Error("unknown operation")
        return public_thread(thread)

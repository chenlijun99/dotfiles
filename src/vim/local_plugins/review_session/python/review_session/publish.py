"""Explicit GitHub publication through gh, with stable retry markers and receipts."""
from __future__ import annotations

import json
import re
from typing import Any

from .core import digest, require, run


def api(endpoint: str, payload: dict | None = None) -> Any:
    args = ["gh", "api", endpoint]
    if payload is not None:
        args += ["--method", "POST", "--input", "-"]
    return json.loads(run(args, data=payload))


def pages(endpoint: str) -> list[dict]:
    result = []
    page = 1
    while True:
        batch = api(f"{endpoint}?per_page=100&page={page}")
        result.extend(batch)
        if len(batch) < 100:
            return result
        page += 1


def patch_lines(patch: str, side: str) -> set[int]:
    allowed = set()
    old = new = 0
    for line in patch.splitlines():
        match = re.match(r"@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@", line)
        if match:
            old, new = map(int, match.groups())
        elif line.startswith("+"):
            if side == "new":
                allowed.add(new)
            new += 1
        elif line.startswith("-"):
            if side == "old":
                allowed.add(old)
            old += 1
        elif line.startswith(" "):
            allowed.add(old if side == "old" else new)
            old += 1
            new += 1
    return allowed


def publish(state: dict, thread: dict, args: dict, send: bool) -> dict:
    require(args.get("role", "human") == "human", "only human may publish")
    draft = thread["draft"]
    require(draft, "select a message revision with draft first")
    require(not args.get("revision") or args["revision"] == draft["revision"], "selected draft changed; preview again")
    destination = args.get("destination", "")
    match = re.fullmatch(r"([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)#([1-9][0-9]*)", destination)
    require(match, "destination must be owner/repo#number")
    assert match is not None
    repo, number = match.groups()
    pull = f"repos/{repo}/pulls/{number}"
    pr = api(pull)
    require(pr["state"] == "open", "destination PR is not open")
    anchor = thread.get("publication_anchor", thread["anchor"])
    summary = bool(args.get("summary")) or anchor["scope"] == "review"
    if not summary:
        require(anchor["new_ref"] != "WORKTREE" and not anchor["new_ref"].startswith("INDEX:") and not anchor["old_ref"].startswith("INDEX:") and anchor["old_ref"] != "WORKTREE", "mutable anchors require explicit reanchor or --summary")
        require(pr["head"]["sha"] == anchor["new_ref"], "PR head does not match original context; explicitly reanchor or publish --summary")
        diff_base = api(f'repos/{repo}/compare/{pr["base"]["sha"]}...{pr["head"]["sha"]}')["merge_base_commit"]["sha"]
        require(anchor["old_ref"] == diff_base, "original context does not use the PR merge base; explicitly reanchor or publish --summary")
    identity = digest([thread["id"], draft["revision"], destination, summary, None if summary else [anchor.get("fingerprint"), anchor.get("side"), anchor.get("start"), anchor.get("end")]])
    marker = f"<!-- review-session:{identity} -->"
    payload = {"body": draft["body"] + "\n\n" + marker}
    endpoint = f"repos/{repo}/issues/{number}/comments" if summary else pull + "/comments"
    if not summary:
        files = pages(pull + "/files")
        target_path = anchor.get("new_path") or anchor.get("old_path")
        file = next((f for f in files if f["filename"] == target_path or (anchor.get("old_path") and f.get("previous_filename") == anchor["old_path"])), None)
        require(file, "anchor path is not in destination PR")
        assert file is not None
        require(anchor.get("old_path") == (file.get("previous_filename") or file["filename"]) or (anchor.get("old_path") is None and file.get("status") == "added"), "original old path does not match destination diff")
        require(anchor.get("new_path") == file["filename"] or (anchor.get("new_path") is None and file.get("status") == "removed"), "original new path does not match destination diff")
        payload.update(commit_id=anchor["new_ref"], path=file["filename"])
        if anchor["scope"] == "file":
            payload["subject_type"] = "file"
        else:
            side = anchor["side"]
            allowed = patch_lines(file.get("patch", ""), side)
            require(all(n in allowed for n in range(anchor["start"], anchor["end"] + 1)), "anchor range is outside destination PR diff")
            payload.update(side="LEFT" if side == "old" else "RIGHT", line=anchor["end"])
            if anchor["start"] != anchor["end"]:
                payload.update(start_line=anchor["start"], start_side=payload["side"])
    preview = {"destination": destination, "endpoint": endpoint, "payload": payload, "draft": draft, "receipt": state["publications"].get(identity)}
    preview["token"] = digest([endpoint, payload])
    require(not args.get("expected_preview") or args["expected_preview"] == preview["token"], "publication target or draft changed; preview again")
    if not send or preview["receipt"]:
        return preview
    # A network failure after POST may lose the local transaction; the remote marker recovers the receipt.
    existing = next((c for c in pages(endpoint) if marker in c.get("body", "")), None)
    remote = existing or api(endpoint, payload)
    receipt = {"id": remote["id"], "url": remote["html_url"], "destination": destination,
               "thread": thread["id"], "revision": draft["revision"]}
    state["publications"][identity] = receipt
    preview["receipt"] = receipt
    return preview

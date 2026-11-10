"""Read exact Git, index-stage and saved working-tree file pairs."""
from __future__ import annotations

import base64
import os
import stat
import subprocess
from pathlib import Path

from .core import Error, digest, git, read_blobs, require, revision, tree


def selector(repo: str, value: str | None) -> str:
    require(value is None or isinstance(value, str), "version must be a string")
    if value in (None, "WORKING", "WORKTREE"):
        return "WORKTREE"
    if value in ("INDEX", ":0", "INDEX:0"):
        return "INDEX:0"
    if value in (":1", ":2", ":3", "INDEX:1", "INDEX:2", "INDEX:3"):
        return "INDEX:" + value[-1]
    return revision(repo, value)


def blob(repo: str, ref: str, path: str | None, cache: dict) -> dict | None:
    if path is None:
        return None
    require(isinstance(path, str) and path and not Path(path).is_absolute() and ".." not in Path(path).parts, "invalid repository-relative path")
    if ref == "WORKTREE":
        filename = Path(repo) / path
        try:
            info = filename.lstat()
            if stat.S_ISLNK(info.st_mode):
                mode, data = "120000", os.fsencode(os.readlink(filename))
            elif stat.S_ISREG(info.st_mode):
                require(filename.resolve().is_relative_to(Path(repo)), "source path escapes repository")
                mode, data = ("100755" if info.st_mode & stat.S_IXUSR else "100644"), filename.read_bytes()
            elif stat.S_ISDIR(info.st_mode):
                mode, data = "160000", git(str(filename), "rev-parse", "HEAD").strip()
            else:
                raise ValueError("unsupported source file type")
        except FileNotFoundError:
            return None
        return {"mode": mode, "data": base64.b64encode(data).decode()}
    if ref.startswith("INDEX:"):
        if "index" not in cache:
            cache["index"] = index(repo)
        item = cache["index"].get((ref[-1], path))
        if item is None:
            return None
        mode, oid = item
        key = ("blob", oid)
        if key not in cache:
            cache[key] = git(repo, "cat-file", "blob", oid) if mode != "160000" else oid.encode()
        return {"mode": mode, "data": base64.b64encode(cache[key]).decode()}
    if ref not in cache:
        cache[ref] = tree(repo, ref)
    return cache[ref].get(path)


def index(repo: str) -> dict:
    result = {}
    for entry in git(repo, "ls-files", "--stage", "-z").split(b"\0"):
        if entry:
            meta, name = entry.split(b"\t", 1)
            mode, oid, stage = meta.decode().split()
            result[stage, os.fsdecode(name)] = mode, oid
    return result


def changed_paths(repo: str, old: str, new: str) -> list[dict]:
    require(not old.startswith("INDEX:") or old == "INDEX:0", "specify explicit files for conflict-stage pairs")
    require(not new.startswith("INDEX:") or new == "INDEX:0", "specify explicit files for conflict-stage pairs")
    if new == "WORKTREE":
        args = [] if old == "INDEX:0" else [old]
    elif new == "INDEX:0":
        require(old not in ("WORKTREE", "INDEX:0"), "unsupported implicit pair; specify files")
        args = ["--cached", old]
    else:
        require(old not in ("WORKTREE", "INDEX:0"), "specify explicit files for reversed mutable pairs")
        args = [old, new]
    entries = iter(git(repo, "diff", "--name-status", "-z", "--find-renames", *args, "--").split(b"\0"))
    result = []
    for status in entries:
        if not status:
            continue
        first = os.fsdecode(next(entries))
        second = os.fsdecode(next(entries)) if status.startswith((b"R", b"C")) else first
        result.append({"old_path": None if status.startswith(b"A") else first, "new_path": None if status.startswith(b"D") else second})
    if new == "WORKTREE":
        result.extend({"old_path": None, "new_path": os.fsdecode(p)} for p in git(repo, "ls-files", "--others", "--exclude-standard", "-z").split(b"\0") if p)
    return result


def capture(view: dict, default_repo: str | None = None) -> list[dict]:
    require(isinstance(view, dict), "view must be an object")
    repo = git(str(Path(view.get("repo") or default_repo or ".").resolve()), "rev-parse", "--show-toplevel").decode().strip()
    resolved = {}
    def resolve(value: str | None) -> str:
        if value not in resolved:
            resolved[value] = selector(repo, value)
        return resolved[value]
    old, new = resolve(view.get("old", "HEAD")), resolve(view.get("new", "WORKTREE"))
    files = view.get("files")
    if files is None:
        if view.get("path") or view.get("old_path") or view.get("new_path"):
            files = [{"old_path": view.get("old_path", view.get("path") or view.get("new_path")), "new_path": view.get("new_path", view.get("path") or view.get("old_path"))}]
        else:
            files = changed_paths(repo, old, new)
    require(isinstance(files, list), "view files must be a list")
    result, cache = [], {}
    ids = set()
    for item in files:
        require(isinstance(item, dict), "file target must be an object")
        for side, default in (("old", old), ("new", new)):
            ref = resolve(item.get(side, default))
            if ref.startswith("INDEX:"):
                if "index" not in cache:
                    cache["index"] = index(repo)
                entry = cache["index"].get((ref[-1], item.get(side + "_probe_path") or item.get(side + "_path") or item.get(("new" if side == "old" else "old") + "_path")))
                if entry and entry[0] != "160000":
                    ids.add(entry[1])
    for oid, data in read_blobs(repo, ids).items():
        cache["blob", oid] = data
    for item in files:
        old_ref, new_ref = resolve(item.get("old", old)), resolve(item.get("new", new))
        old_path, new_path = item.get("old_path"), item.get("new_path")
        if item.get("orient"):
            endpoints = [(old_ref, old_path), (new_ref, new_path)]
            def rank(endpoint: tuple[str, str | None]) -> tuple[int, str, str]:
                ref, path = endpoint
                return (2 if ref == "WORKTREE" else 1 if ref.startswith("INDEX:") else 0, ref, path or "")
            endpoints.sort(key=rank)
            if not any(ref == "WORKTREE" or ref.startswith("INDEX:") for ref, _ in endpoints):
                reverse = subprocess.run(["git", "-C", repo, "merge-base", "--is-ancestor", endpoints[1][0], endpoints[0][0]], capture_output=True, check=False).returncode == 0
                if reverse:
                    endpoints.reverse()
            (old_ref, old_path), (new_ref, new_path) = endpoints
        require(old_path or new_path, "file pair needs a path")
        old_probe = item.get("old_probe_path") or old_path or new_path
        new_probe = item.get("new_probe_path") or new_path or old_path
        if old_path is None and (old_ref == "WORKTREE" or old_ref.startswith("INDEX:")):
            old_path = old_probe
        if new_path is None and (new_ref == "WORKTREE" or new_ref.startswith("INDEX:")):
            new_path = new_probe
        before, after = blob(repo, old_ref, old_path, cache), blob(repo, new_ref, new_path, cache)
        if before is None:
            old_path = None
        if after is None:
            new_path = None
        require(before is not None or after is not None, "file pair has no source on either side")
        fingerprint = digest([repo, old_path, new_path, before, after])
        result.append({"repo": repo, "old_ref": old_ref, "new_ref": new_ref, "old_path": old_path, "new_path": new_path,
                       "old_probe_path": old_probe, "new_probe_path": new_probe, "path": new_path or old_path, "old": before, "new": after, "fingerprint": fingerprint, "key": item.get("key"),
                       "selected_side": ("old" if selector(repo, item["selected_ref"]) == old_ref and item.get("selected_path") == old_path else "new") if "selected_ref" in item else item.get("selected_side")})
    validate_display(result, view.get("observations", []))
    return result


def validate_display(pairs: list[dict], observations: list[dict]) -> None:
    require(isinstance(observations, list), "source observations must be a list")
    refs = {}
    for observed in observations:
        require(isinstance(observed, dict) and isinstance(observed.get("lines"), list), "invalid source observation")
        if not pairs:
            continue
        key = observed.get("ref")
        if key not in refs:
            refs[key] = selector(pairs[0]["repo"], key)
        ref = refs[key]
        for pair in pairs:
            for side in ("old", "new"):
                path = pair[side + "_path"] or pair.get(side + "_probe_path")
                if ref != pair[side + "_ref"] or observed.get("path") != path:
                    continue
                source = base64.b64decode(pair[side]["data"]) if pair[side] else b""
                layout = observed.get("layout", "file")
                if layout == "lines":
                    # Some viewers expose Git text as lines, without original EOL metadata.
                    content = source.decode("utf-8", errors="replace").replace("\r\n", "\n")
                    lines = content.split("\n")
                    if lines[-1] == "":
                        lines.pop()
                    equal = observed["lines"] == (lines or [""])
                else:
                    require(layout == "file", "unknown source display layout")
                    encoding = observed.get("encoding") or "utf-8"
                    encoding = encoding.replace("ucs-2", "utf-16").replace("ucs-4", "utf-32")
                    try:
                        content = source.decode(encoding)
                    except (LookupError, UnicodeError) as error:
                        raise Error("cannot compare displayed source encoding; reload and reselect") from error
                    if observed.get("bomb") and content.startswith("\ufeff"):
                        content = content[1:]
                    separator = {"unix": "\n", "dos": "\r\n", "mac": "\r"}.get(observed.get("fileformat", "unix"))
                    require(separator, "unknown source line format")
                    assert separator is not None
                    has_eol = content.endswith(separator)
                    lines = content.split(separator)
                    if has_eol:
                        lines.pop()
                    equal = observed["lines"] == (lines or [""]) and (not content or bool(observed.get("endofline")) == has_eol)
                require(equal, f'displayed source differs from saved version: {path}; reload the source buffer and reselect')


def descriptor(pair: dict) -> dict:
    return {"repo": pair["repo"], "files": [{"old": pair["old_ref"], "new": pair["new_ref"], "old_path": pair["old_path"], "new_path": pair["new_path"], "old_probe_path": pair.get("old_probe_path") or pair["old_path"] or pair["new_path"], "new_probe_path": pair.get("new_probe_path") or pair["new_path"] or pair["old_path"]}]}


def same_file(left: dict, right: dict) -> bool:
    return left["repo"] == right["repo"] and bool({left.get("old_path"), left.get("new_path")} .intersection({right.get("old_path"), right.get("new_path")}) - {None})


def mutable(pair: dict) -> bool:
    return any(pair[key] == "WORKTREE" or pair[key].startswith("INDEX:") for key in ("old_ref", "new_ref"))


def current(pair: dict) -> bool:
    if not mutable(pair):
        return True
    try:
        return capture(descriptor(pair))[0]["fingerprint"] == pair["fingerprint"]
    except (Error, OSError, ValueError):
        return False

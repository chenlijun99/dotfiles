# CLI contract

`review-session --session DIRECTORY [--role human|agent] COMMAND [OPTIONS]`

Successful commands emit one JSON value and exit 0; runtime errors emit JSON on stderr and exit 1 (argparse usage errors exit 2). Global options precede the command. Bodies use `--body TEXT`, `--body-file FILE`, or `--body-file -` for stdin. No comparison enrollment or fixed session base/head exists.

## File targets

Target flags are `--repo PATH --old VERSION --new VERSION [--path RELATIVE]`. Versions are Git commit references, `INDEX`/`INDEX:0`, `INDEX:1`/`INDEX:2`/`INDEX:3`, or `WORKTREE`. References resolve to exact commits. Default old is HEAD; default new is WORKTREE. `--old-path` and `--new-path` select explicit rename endpoints. Omit path to inspect or explicitly mark the current Git difference list.

For viewer lists or distinct per-row sources, pass `--view-file FILE` with JSON:

```json
{
  "repo": "/path/to/repo",
  "files": [
    {"old": "HEAD", "new": "INDEX:0", "old_path": "src/a.py", "new_path": "src/a.py", "key": "staged:a"},
    {"old": "INDEX:0", "new": "WORKTREE", "old_path": "src/a.py", "new_path": "src/a.py", "key": "unstaged:a"}
  ]
}
```

An absent snapshot side uses a null path. Returned descriptors retain separate logical probe paths so a missing mutable endpoint is checked again after recreation or staging; keep the returned descriptor intact for delayed actions. Pair fingerprints include repository, both paths, original bytes and Git modes, excluding commit IDs and viewer keys. Identical pairs share reviewed status across contexts. Distinct staged/unstaged pairs at one path remain independent. Bulk writes deduplicate identical fingerprints and never enroll unseen comparisons.

`view` returns a response wrapper containing resolved file target descriptors and fingerprints without writing session state. For one file, extract `response["files"][0]["view"]` into the JSON used by `--view-file`; do not pass the whole response wrapper as a descriptor. Delayed composition should use its returned descriptor plus `--expected-fingerprint TOKEN` when creating a thread, so a changed mutable pair is rejected transactionally. Programmatic clients may send the whole command-specific argument object using `--request-file FILE` or `--request-file -`; Neovim sends `{"view": {...}, "scope": "range", ...}` this way. `mark` also accepts `expected_fingerprints` in this JSON interface.

Programmatic source actions can include an `observations` array inside the view. Each observation identifies a loaded endpoint by `ref`/`path` and supplies its displayed `lines`, `fileformat` (`unix`, `dos`, `mac`), `endofline`, `encoding` and `bomb` read metadata. Capture validates those unmodified-buffer observations against saved source before returning a view or writing a thread/mark, rejecting stale displays with reload/reselect guidance. Preserve observations with delayed descriptors. The existing codediff adapter uses `layout: "lines"` because its programmatically populated Git buffers normalize CRLF and omit reliable final-newline metadata; exact saved bytes and metadata still determine the fingerprint and retained snapshot. Observations are temporary action evidence, never session records or render-time queries.

## Commands

- `init [--repo PATH]`: create a session directory, storing a default repository hint (default cwd). Existing sessions are never overwritten; subsequent actions can target other repositories explicitly.
- `view TARGET` (alias `status`): read-only current file-pair status, exact reviewed count and total. Each `reviewed` field is `reviewed`, `another` or `pending`; another implies neither ordering nor partial coverage. Navigation never persists snapshots or session activity.
- `mark TARGET [--value toggle|reviewed|pending]`: deliberately capture/mark only the supplied file pairs. Toggle marks all if any is not exact-reviewed; otherwise clears those exact marks. Other pairs remain marked.
- `history [TARGET]`: list captured reviewed pairs, optionally restricted to files relevant to the target. Results retain original version references, paths, fingerprints, modes and source snapshots.
- `create TARGET [--scope review|file|range] [--side old|new] [--start N] [--end N] BODY`: create a thread at the current exact pair. Range is inclusive and one-based; end defaults to start. Agent threads start shared; human threads start human-only. Explicit `--scope review` creates a review-wide note without needing a file view.
- `threads [TARGET]`: visible threads. With a target, include review-wide notes and relevant file threads across pairs, labelled `other_revision`; without a target, list the session. A historical original does not move when you navigate.
- `queue`: shared threads with pending human message IDs, exact revision tokens and bodies. Untouched outdated mutable threads are excluded; deliberate new human input on an outdated thread remains actionable. Resolved does not mean acknowledged.
- `show --thread ID`: thread structure and Markdown view.
- `source --thread ID [--side old|new]`: original UTF-8 source (replacement decoding), exact base64 blob and mode. Missing sides are null with empty text. `--fingerprint TOKEN` instead of thread retrieves a reviewed pair's retained source.
- `context --thread ID` (or `--fingerprint TOKEN`): original anchor and whether its original Git/index/worktree sources are still available with matching bytes, for viewer reopening or snapshot fallback.
- `reply --thread ID [--ack REVISION ...] BODY`: append input. Only agents acknowledge; stale/superseded tokens never clear a current human revision. Reading is not acknowledgement.
- `edit --thread ID --message ID --revision EXPECTED BODY`: edit your role's message with concurrency checking. Every accepted edit changes its revision, including edit-and-revert.
- `share --thread ID [--value shared|human-only]`: human-only sharing control (default shared).
- `resolve --thread ID [--value resolved|open]`: discussion state (default resolved), independent of agent handling and drafts.
- `reanchor --thread ID TARGET [--scope file|range] [--side old|new] [--start N] [--end N]`: explicitly select a separate publication location, retaining the original anchor/snapshots. Human only.
- `draft --thread ID --message ID --revision EXPECTED`: select a frozen body/revision for publication. Human only; later message edits do not silently replace it.
- `preview --thread ID --destination OWNER/REPO#NUMBER [--revision EXPECTED_DRAFT] [--summary]`: validate and show the selected payload/receipt without posting. `--summary` explicitly chooses a PR-wide issue comment, allowing incompatible intermediate anchors without remapping them.
- `publish` with those same options: validate and post or recover a receipt. Human only. An inline anchor must match the PR's committed head, merge base and path/side/range; otherwise explicitly reanchor or choose summary.
- `coverage [--target LABEL] [BODY]`: append review-level evidence when a body is supplied; otherwise retrieve records. Keep target/base, intended behavior, guidance and checklist here once per review rather than duplicating them into findings.

IDs and revision tokens are opaque. Session format 2 uses one SQLite database and belongs entirely to its disposable directory. Role filters assist context selection rather than enforcing filesystem access control. Never edit SQLite directly; no CLI operation writes source files or source repository refs.

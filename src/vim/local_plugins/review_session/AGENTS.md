# review_session agent notes

Read CONTEXT.md and docs/adr/0001-viewer-driven-sessions.md for accepted terms and scope. A session collects review activity without fixed comparisons or enrollment. Navigation must never write SQLite or retain source snapshots; read commands use SQLite mode=ro. Explicit thread/reviewed actions capture actual version pairs.

Python owns persistence, target identity, queue, reviewed and publication policy. Lua only describes viewers, composes Markdown, queries batches asynchronously and decorates cached results. Never write the database from Lua or reproduce fingerprint/attention rules there.

Keep codediff and Fugitive internals in their optional adapters. Bulk uses actual complete row pairs, including collapsed directories and distinct staged/unstaged rows at one path. Fugitive status is HEAD:index or index:worktree, restricted to its current section. Actual diff endpoints, not window placement, identify sides. CodeDiff symbolic source_revisions are refresh dependencies, not action identities; use resolved displayed explorer endpoints and history bases/commit parents, preserving per-row index/worktree selectors. Reject unsaved, ambiguous or three-way source actions. Explicit actions collect targeted loaded-endpoint display observations and validate them against saved source in the CLI; an unmodified stale worktree/index buffer must trigger reload/reselect, never capture a different displayed version. Keep format normalization in that validation, not a second fingerprint implementation. Navigation/rendering must not collect observations or perform validation queries.

Session selection is tab-local; new viewer tabs inherit their originating selection without writes. Shared buffers require active-context-only annotation painting. Tab/session switches clear/repaint cache synchronously, including unloaded/no-context and failed paths; inactive async responses may not paint.

Original anchors and source snapshots are immutable. Explicit publication reanchor is separate; incompatible inline publication requires that or explicit summary. Message edits use expected revisions; responses acknowledge exact human revisions. Human-only is a context filter, not secrecy.

Run the documented Python, ordinary editor and actual codediff/Fugitive tests. Publication tests must mock gh, never post. Plugin CLI skill is skills/review-session/SKILL.md; the repository's clj-review-session wrapper layers its existing clj-code-review process. The old review_tracker is superseded; never insert or strip source REVIEWED markers as migration.

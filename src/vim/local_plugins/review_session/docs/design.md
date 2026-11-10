# Viewer-driven session design

The [accepted decision](adr/0001-viewer-driven-sessions.md) makes the session a workspace collecting activity, with no fixed comparison. Python owns persisted domain rules; Lua sends viewer descriptors to the same CLI used by independent agents.

## Reads and explicit capture

Read-only commands open SQLite with `mode=ro`; navigation does not create tables, transactions, journal files, snapshots or comparison records. Computing live indicators may read Git/index/filesystem content, but those temporary bytes are not retained. `create` and `mark` deliberately capture exact source pairs; other explicit message/publication operations update their own session records.

A file pair contains repository identity, separate old/new paths, bytes and Git modes. Commit IDs and mutable selectors describe how to reopen it but are excluded from the reviewed fingerprint, so an unchanged pair retains status across commits and viewers. Null paths canonically represent absent snapshots. Separate logical probe paths let mutable endpoints detect later recreation or staging; the same re-probe applies to availability, outdatedness and delayed-write validation without changing original null snapshots. Reviewed records retain snapshots and identify which versions were reviewed; another-pair hints are session-wide per-file evidence, without ordering or partial coverage claims.

Targets support committed revisions, actual index stages and saved working-tree text, including binary, deleted and symbolic-link files without changing source. Bulk operations use complete viewer lists, including collapsed nodes; distinct staged/unstaged rows at one path stay separate. At initial explicit selection, the frontend supplies unmodified loaded-endpoint observations in the same batch. Python checks displayed lines and read-format metadata against captured saved source, rejecting stale working/index displays with reload/reselect guidance; no buffer is saved or reloaded automatically. Observations stay temporary and travel with delayed writes. Mutable source changes after selection also reject the expected fingerprint while retaining the editing buffer. Codediff’s line-only Git presentation is checked using its normalized visible lines; exact saved bytes still own identity and snapshots.

## Persistence and attention

A session directory contains one versioned JSON record inside SQLite, plus transient SQLite files during explicit writes. `BEGIN IMMEDIATE`, a busy timeout, full synchronous commits and rollback serialize writers. Message edits additionally check their expected revision. This store favors simple atomic operations; large-tree capture and JSON rewriting remain unbenchmarked.

Original thread anchors/snapshots never move. A separate explicit publication anchor can be selected without changing original context, discussion state or pending human revisions. Historical committed anchors stay attached to their original commits. Mutable anchors become outdated when their actual index/worktree file pair changes; the normal agent queue excludes untouched outdated input. Human replies/edits made while outdated explicitly request attention. Acknowledgements name exact human message revision tokens and cannot clear later edits or edit-and-revert cycles.

Human-only filtering, discussion resolution, agent acknowledgement, reviewed status and publication drafts are independent. Human-only is not filesystem secrecy. Review coverage is a session-level evidence record, not inferred from resolved threads or file toggles.

## Viewer seam and cached UI

Optional adapters implement `resolve(all)` to describe exact active source endpoints, `decorate(cache)`/`clear()` for display and `open(anchor, done, failed)` for original context, with failure completion for asynchronous viewers. Codediff internals stay in its adapter; per-row comparison logic handles HEAD/index/worktree sources and historical commit rows. Actions use resolved displayed explorer/history endpoints; symbolic source_revisions remain viewer refresh dependencies and are never substituted for displayed versions. A transitional unresolved list/source combination requires refresh and reselection. Fugitive uses public buffer identity APIs plus its status file records, and requires exactly two identifiable diff partners for line/range actions. Three-way and ambiguous diffs produce explicit action errors.

Fugitive supplies no canonical pane direction. The domain orients committed ancestors first, then index, then worktree; unrelated commit endpoints use stable lexical commit-ID order. Selected-side identity comes from the actual endpoint, independently of window placement. Status pairs are explicitly HEAD:index or index:worktree and bulk only selects the current section.

Session selection is tab-local. A newly created viewer tab inherits its originating tab's selected session, without storage writes. Existing selections are retained. Only the active context paints buffer-wide annotations, since viewers may reuse source buffers across tabs; selection/tab changes clear and repaint cached annotations before asynchronous requests. Inactive responses do not paint. Render callbacks consume cache, with no process per row or redraw.

The thread picker defaults to files in the active view, with a session-wide option. Choosing another original pair uses the preferred viewer (codediff by default); if Git objects or original mutable text are unavailable, or the viewer cannot represent the exact pair, snapshots remain inspectable in ordinary read-only source buffers. Codediff uses native single-revision commit:worktree and staged commit:index commands; unsupported index:worktree combinations fall back immediately. Open hooks are removed on completion/failure, with a bounded fallback if an asynchronous command never signals a selected file. Thread Markdown reloads explicitly with R. Composition uses normal Markdown `acwrite` buffers and all writes go through the CLI.

## Publication

Only a frozen selected draft is outgoing. Inline publication requires committed source applicability to the destination PR, including exact head, GitHub merge base, rename/path metadata and diff coordinates. An explicit publication anchor or PR-wide summary handles incompatible original intermediate contexts; no automatic remapping occurs. Summary has no source coordinates and therefore does not impose inline head/base equality.

The publisher records remote IDs/URLs and uses stable hidden markers to recover a successful POST whose local response or commit was lost. Removing both the local receipt and remote marker prevents automatic recovery. Publication is a separate authorized action; navigation, findings and local drafts never post remotely.

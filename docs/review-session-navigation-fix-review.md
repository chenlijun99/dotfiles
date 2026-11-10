# Review session navigation lifecycle fix review

## Current status

**Accepted after round 2, no unresolved findings.** Deleted selections unload quietly; explicit loads validate independently of source; in-memory selection ownership prevents stale missing responses from cancelling newer same-path selections. All 22 Python tests, five Lua suites and original deletion/race probes pass independently. Earlier round-1 findings below are historical and resolved by the final recheck. Lead final standalone/static/Nix audit also passed, recorded separately below.


## Target and guidance

- Comparison base: `c7f0c1f` (HEAD); scope is the new missing/deleted-session lifecycle fix, excluding unrelated fcitx change.
- User scenario: delete a selected session directory while Neovim stays open, then navigate CodeDiff. Passive navigation should invalidate the missing selection quietly, without repeated queries/errors or stale inheritance.
- Explicit missing loads should report once without selecting. Valid stores must load even if source/Git is unavailable. Source/Git/other errors remain visible without discarding valid selections. Valid read-only navigation, inheritance/isolation, writes and source guards remain intact.
- Guidance: personal-AGENTS.md and provided root instructions, plugin AGENTS.md/CONTEXT.md/ADR, `clj-code-review` scope/evidence rules. Original completed implementation review remains in its separate notes file. Reviewer edits only this new record; no implementation/Git/remote mutations.

## Preliminary checklist

- [ ] Error classification distinguishes missing session from source/Git/validation/storage failures.
- [ ] Explicit attach validates session without depending on source availability, reports missing once, and never selects it.
- [ ] Deleted active sessions invalidate on passive reads with no repeated requests/notices or stale inherited selections.
- [ ] Pending attach/read callbacks cannot clobber newer valid selection or recreated same-path session.
- [ ] Valid-session read-only navigation, inheritance/isolation, writes and source guards remain unchanged.
- [ ] Meaningful Python and actual CodeDiff lifecycle regressions, failure-path/race probes and verification limits.

## Round 1 finding

**[P2] A delayed missing-session response invalidates a newer valid selection at the same path.** `lua/review_session/init.lua:30-37` invalidates contexts/origins by session pathname, and `request` invokes that path-wide operation at lines 62-64 before checking whether the response owns the current selection. The load success callback has a `loads[tab] == ctx` guard, but missing load/read responses do not have equivalent ownership protection.

Concrete actual CLI/CodeDiff reproduction in `/tmp/review-session-delayed-missing-race.lua`:

1. Load a valid session and retain its selected context.
2. Delete its directory, then start a passive refresh. Hold delivery of the real CLI `missing_session` response.
3. Recreate the session at the same directory, explicitly attach it, and wait until the new context has a valid cache.
4. Deliver the old missing response. `review.context()` becomes nil and the newer context is marked invalid.

This loses a successfully selected replacement workspace, clears its inheritance and causes later review actions to require another load. No persisted data loss was observed. It violates the requested stale-callback safety, so it should be fixed before accepting this focused change. Scope invalidation to the selection/generation that issued the request and its inherited contexts, rather than all contexts with the same pathname. Keep stale callbacks from invalidating a later explicit attach even when the path is unchanged. An in-memory ownership token or shared selection identity suffices; do not add a persistent database identity/schema solely for UI callback ownership. Cover delayed missing read and pending load responses, later same-path valid selection, and inherited children while retaining the original quiet-deletion behavior.

## Checklist evidence and dispositions

- [x] **Error classification:** new MissingSession subclass/machine code is confined to absent session path/database and missing-during-connect. Source/Git errors retain ordinary errors; Python regression checks this after removing the source repo. Reviewer additionally exercised corrupt existing SQLite and an unreadable session directory; both produce visible ordinary errors without `missing_session`.
- [x] **Explicit loading:** `load` reads/verifies the session independently of source/Git and uses SQLite mode=ro. Python regression confirms unchanged database bytes/mtime and successful load after repository removal. Actual viewer regression confirms a missing requested load is not selected or created, reports once and is not retried/inherited. Previous selected-context preservation on an explicit failed selection is not required here; a failed request leaves no active workspace.
- [x] **Deleted selected session:** independently ran the exact user-scenario `/tmp/review-session-deleted-session.lua`; deleted session unloads with no raw passive error, later FileSelect produces no queries/notices, and failed-load navigation remains quiet. Actual new `tests/codediff_session.lua` checks parent/child selection invalidation, subsequent navigation silence and explicit-action load guidance, passing.
- [x] **Callback/inheritance ownership:** inspected pending loads, invalid-request exits, successful callback guards, origins/leaving cleanup and closed-tab cleanup. The delayed actual missing-response probe above fails and exposes the remaining ownership defect. New current tests serialize deletion/reattach and do not cover that race. Different-path success responses are guarded by per-tab loads identity; same-path old missing responses still need a corresponding invalidation guard.
- [x] **Valid-session behavior:** new actual viewer regression confirms unchanged SQLite bytes for load/navigation, normal viewer-tab inheritance, visible source error with retained selection, successful recovery after source error, and existing explicit action guidance with no workspace. Existing ordinary/CodeDiff/symbolic/Fugitive suites still exercise read-only navigation, source guards, inheritance and shared-buffer isolation, all pass.
- [x] **Verification:** reviewer ran all **22 Python tests**, **all five Lua suites** (`editor`, `codediff`, `codediff_symbolic`, `codediff_session`, `fugitive`), the exact external deletion probe and `git diff --check`, all passing. The targeted stale-response probe fails as described. Ordinary editor tests emit expected explicit missing-load/source diagnostics; focused passive-deletion tests assert silence.

## Limits and review status

One concrete P2 remains; the original reported deletion error is fixed in the sequential user path. Read-only load validation and machine error classification are appropriately small additions and keep source failures distinct. The remaining fix belongs to in-memory callback ownership, without changing session storage or adding general async infrastructure.

No live GitHub/Jira access, repository Git mutation, source implementation edits, broad platform matrix or process-kill SQLite fault injection. This focused review does not reopen the previously completed full implementation review. Round 1 of at most 3 is complete; implementation should address the callback race before recheck.

## Round 2 recheck and acceptance

The sole callback-ownership finding is **fixed and accepted**. Explicit loads now allocate a small in-memory selection token, inherited contexts share only their originating token, and invalidation/request callbacks check that ownership. A missing response invalidates its old selection family without touching a later explicit attach at the same path. No persistent ID, schema change or backend abstraction was added for this race.

- Reviewer inspected token creation/propagation, request early/callback guards, contexts/origins/leaving invalidation and pending-load identity checks. Old composed buffers remain bound to the old selection, so callbacks cannot silently revive it or write through the replacement selection.
- Independently reran original `/tmp/review-session-delayed-missing-race.lua`, exit 0: the replacement remains selected after delivery of the real old missing response.
- Independently reran exact user deletion probe `/tmp/review-session-deleted-session.lua`, exit 0: initial no-session, deleted selection and subsequent failed-load navigation remain quiet without CLI retries.
- Expanded actual `tests/codediff_session.lua`, exit 0: old missing read after same-path successful replacement preserves both replacement parent/child, while clearing the old inherited family. Old missing load delivered before a later successful pending-load callback does not cancel that new selection. Subsequent navigation/inheritance stays valid and silent.
- Reviewer reran all **22 Python tests** and all **five Lua suites** (`editor`, `codediff`, `codediff_symbolic`, `codediff_session`, `fugitive`), all pass. `git diff --check` passes. Expected explicit-load and source-validation diagnostics remain visible; passive missing-session cases assert silence.

All focused checklist requirements are satisfied by the inspected source and recorded evidence, with no unresolved finding. The original complete implementation review remains separate. Lead final standalone/packaging audit is not repeated here and remains with the lead. No live remote posts, broad platform matrix or process-kill filesystem/SQLite race matrix was performed.

## Final lead-provided audit

The lead independently reports both original deletion/race probes passing, a clean standalone copy passing all 22 Python tests and five Lua suites, clean Ruff/ty/diff checks, and successful Nix build/installed `load` smoke at `/nix/store/5bw9azqx3fqr5b0z0xssagdrjfbcm4y2-review-session`. These are lead-provided checks in addition to reviewer evidence above. No focused audit remains pending; no implementation source changed during reviewer verification.

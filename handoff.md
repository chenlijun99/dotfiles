# Viewer-driven review workspace implementation

The user revised the accepted design after reviewing the fixed-comparison prototype. The authoritative decision is `src/vim/local_plugins/review_session/docs/adr/0001-viewer-driven-sessions.md`; `docs/agent-review-workflow-research.md` now points to it and preserves earlier research as historical evidence. The plugin-local CONTEXT.md defines the agreed terms. Do not restore mandatory comparison setup or navigation-triggered session writes.

## Current implementation state

- `src/vim/local_plugins/review_session/` implements flexible sessions. Python format 2 records exact action-captured file pairs, immutable thread anchors, reviewed pairs/history, exact-revision discussions, coverage, explicit publication drafts, reanchors and receipts.
- `load`, `view`, `threads` and other navigation queries use read-only SQLite connections. Only explicit actions persist snapshots or session activity. No named comparison is required. Deleted workspaces unload quietly during passive navigation; selection ownership protects later same-path loads from stale callbacks.
- Lua uses actual viewer descriptors from optional codediff and Fugitive adapters; ordinary buffers use saved index/worktree pairs. Session selection remains tab-local, with originating-session inheritance for new normal viewer tabs and active-context decoration isolation.
- All 22 Python tests and five portable Neovim suites pass from a clean standalone copy, including actual codediff/Fugitive, symbolic-ref explorer/history and missing-session lifecycle regressions. Independent review and the lead's requirement audit are complete; findings are resolved in `docs/review-session-review-notes.md` and `docs/review-session-navigation-fix-review.md`. Capture uses resolved displayed endpoints, validates stale/unsaved source, and preserves read-only navigation.
- Portable CLI skill: `skills/review-session/SKILL.md` inside the plugin. Repository wrapper: `src/nixos/modules/ai/codex/skills/clj-review-session/SKILL.md`, layered on clj-code-review. Both install through `src/nixos/modules/ai/codex/skills.nix`; validation and an independent temporary-fixture forward test passed.
- The old review_tracker replacement, VCS registration and Nix CLI/runtime packaging remain in place. No source REVIEWED text was removed.
- Final packaging checks passed: Nix build and installed CLI init/view/queue, clean wheel build/install and console init/queue. Ruff, ty, whitespace checks, both skill validators, declarative skill-link evaluation and an independent skill usage fixture passed.

Accepted limits: three-way/ambiguous diff actions are unsupported; unsupported exact viewer pairs use retained snapshots; thread views reload with R. Live GitHub publication, interactive fzf, broad platform compatibility and large-repository performance were not exercised. Publication behavior was verified with mocked responses.

## Checks

From the dotfiles root:

```sh
python3 -m unittest discover -s src/vim/local_plugins/review_session/tests -v
nvim --headless -u NONE -l src/vim/local_plugins/review_session/tests/editor.lua
nvim --headless -u NONE -l src/vim/local_plugins/review_session/tests/codediff.lua
nvim --headless -u NONE -l src/vim/local_plugins/review_session/tests/codediff_symbolic.lua
nvim --headless -u NONE -l src/vim/local_plugins/review_session/tests/codediff_session.lua
nvim --headless -u NONE -l src/vim/local_plugins/review_session/tests/fugitive.lua
ruff check src/vim/local_plugins/review_session/python src/vim/local_plugins/review_session/tests
ty check src/vim/local_plugins/review_session/python
git diff --check
```

Actual viewer checks use installed plugins (`CODEDIFF_RTP` and `FUGITIVE_RTP` override their directories). Publication is mocked; do not post to GitHub for tests. Read `~/.codex/personal-AGENTS.md` and applicable AGENTS.md before future edits. Preserve unrelated `src/config/fcitx5/profile` changes and historical research. Reviewer-owned notes must not be edited by implementation workers. No remote posts were made.

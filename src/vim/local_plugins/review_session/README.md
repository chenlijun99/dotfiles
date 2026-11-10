# review_session.nvim

A disposable review workspace shared by a human, coding agents and Neovim. Load a session, navigate code normally, then collect threads and exact reviewed file pairs when you choose. Sessions have no fixed base/head and need no comparison setup.

Requires Neovim 0.10+, Python 3.10+ and Git. Optional viewers are codediff.nvim and Fugitive; fzf-lua supplies the optional fuzzy picker. GitHub publication additionally needs authenticated `gh`. Python uses only the standard library.

## Install and start

```lua
{
  dir = vim.fn.expand("~/.vim/local_plugins/review_session"),
  config = function() require("review_session").setup() end,
}
```

For a standalone checkout, add `bin/` to PATH or `pip install .`. Neovim invokes the bundled CLI directly. `default.nix` packages the CLI with Python, Git and gh; the dotfiles Neovim module includes it and Python in both profiles.

```vim
:ReviewInit /tmp/my-review /path/to/repo
:ReviewSession /tmp/my-review
:CodeDiff HEAD~2 HEAD~1
```

Create a session once; use `ReviewSession` to reload it after restarting. A requested session is selected only after read-only validation. If you delete it while Neovim is running, the next read unloads its selection and inheritance quietly; normal viewer navigation continues without repeated errors. Both commands accept an explicit directory. Source navigation uses normal viewer commands, including `:CodeDiff`, `:Gdiffsplit` and Fugitive `:Git` status. New viewer tabs inherit the originating tab's session; existing tabs retain their own choices. Distinct sessions in one repository remain independent.

Navigation performs read-only queries, with no session writes, snapshot persistence or comparison enrollment. Creating a thread or explicitly marking a pair reviewed captures its actual versions. Working-tree anchors use saved disk content; save source edits first. Explicit actions also check loaded source against the saved version. If an external edit leaves an unmodified working or index buffer stale, reload it through its viewer and reselect; the plugin never saves that stale buffer over the external change. Normal source buffers use index:worktree pairs.

```lua
require("review_session").setup({
  python = "python3",
  codediff = true,
  fugitive = true,
  viewer = "codediff", -- preferred original-thread context; or "fugitive"
  keys = true,         -- false disables <leader>rv and <leader>rV
  -- cli = "/path/to/bundled/python/script",
  -- viewer = function(anchor, done) ...; done(); return true end,
})
```

## Reviewed status

`<leader>rv` or `:ReviewToggle` toggles the current file pair. `<leader>rV` or `:ReviewToggleAll` toggles the current viewer's change list, including collapsed directories. It does not mark all activity collected by the session. Fugitive status bulk applies only to the current staged or unstaged section, with distinct HEAD:index and index:worktree pairs.

- `✓ reviewed`: this exact old/new content, paths and modes were reviewed.
- `◐ another revision reviewed`: a different pair of the file was reviewed in the session. This implies neither ordering nor partial coverage.
- `○ pending`: no pair of that file has been marked.

Identical content/metadata pairs retain their mark across commits and viewer contexts. Reviewing a different pair adds an independent mark. `:ReviewReviewed` inspects reviewed versions for the current view; `:ReviewReviewed!` lists the whole session and opens a selected original pair. `:ReviewProgress` reports current-view totals and statuses. Source files are never changed or stripped of existing REVIEWED text.

## Discussions

`:ReviewNote` composes a review-wide note. `:ReviewFile` creates a file note. `:ReviewComment` creates a line note, or use `:'<,'>ReviewComment` for a range. Fugitive status rows support file notes and review toggles; line/range notes require an open diff. Ambiguous partners and three-way diffs produce an action error rather than guessing.

Save the normal Markdown composition with `:write`. Failed writes keep your modified buffer. A changed pair during composition rejects the stale save and preserves your text; reopen at the intended context and copy the note. Subsequent saves edit the same message, using a revision check to avoid overwriting concurrent edits.

`:ReviewThreads` picks threads relevant to the current view, including other revisions of its files. `:ReviewThreads!` picks across the session. Selecting a thread from another version opens its original context in the preferred viewer, falling back to retained source snapshots if Git objects or mutable versions are unavailable, or the preferred viewer cannot represent the exact pair. Codediff opens commit:worktree and commit:index natively; index:worktree and other unsupported endpoint combinations use exact retained snapshots immediately. Asynchronous viewer failure also completes through snapshot fallback. A thread's identity never depends on its viewer.

Thread views are navigable read-only Markdown:

- `R`: reload external replies and state.
- `r`: compose a reply; `e`: select a human message to edit.
- `s`: share/unshare; `x`: resolve/reopen discussion.
- `o` / `O`: inspect original/opposite source snapshots.
- `d`: select a specific message revision as a frozen publication draft.
- `p`: preview inline publication; `P`: explicitly preview a PR-wide summary.

Human-created threads start human-only; agents create shared threads. Human-only is a context filter, not filesystem secrecy. Discussion resolution, agent acknowledgement and publication selection remain separate. Message revisions change on every edit, including edit-and-revert cycles.

Source annotations use the active tab's cached session only. Switching tabs/sessions clears and repaints synchronously before asynchronous queries, including viewers that share source buffers. Render hooks never launch a CLI process per file or redraw.

## Agent CLI

```sh
review-session --session /tmp/my-review init --repo /path/to/repo
review-session --session /tmp/my-review --role agent queue
review-session --session /tmp/my-review --role agent show --thread THREAD
review-session --session /tmp/my-review --role agent reply --thread THREAD \
  --ack EXACT_HUMAN_REVISION --body-file response.md
```

Reading does not acknowledge. Repeat `--ack` for each handled revision; an old response cannot clear later human input. Untouched outdated mutable anchors can leave the usual queue, while deliberate new human input requests attention again. Historical committed anchors stay immutable as you navigate other commits.

Agents use the same file-pair model without an editor or comparison enrollment:

```sh
review-session --session /tmp/my-review view --repo /path/to/repo \
  --old HEAD~2 --new HEAD~1 --path src/example.py
review-session --session /tmp/my-review --role agent create \
  --repo /path/to/repo --old HEAD~2 --new HEAD~1 --path src/example.py \
  --start 12 --end 14 --side old --body-file finding.md
review-session --session /tmp/my-review mark --repo /path/to/repo \
  --old INDEX --new WORKTREE --path src/example.py
```

`coverage --target LABEL --body-file evidence.md` appends session-level review evidence. Review-level findings can omit a file path; file notes omit the range. See [the CLI contract](docs/cli.md) for bulk descriptors and delayed composition guards.

## Agent skills

The portable [review-session skill](skills/review-session/SKILL.md) teaches explicit session/role selection, original-source retrieval, exact revision acknowledgements and local findings/coverage. The dotfiles Codex module installs it as an editable link together with `clj-review-session`, a wrapper around the existing independent `clj-code-review` workflow that writes shared finding threads and one review-level coverage record into the specified session. Neither skill authorizes remote publication.

## Publication and lifetime

Publishing uses only an explicitly selected frozen message revision. The destination PR must be open. Inline comments require original committed versions matching the PR head and merge base, plus valid path/side/range coordinates in the PR diff. An intermediate or mutable anchor is never silently mapped.

Use `:ReviewReanchor THREAD` at a new file location, or a visual range with that command, to select a publication location while preserving the original anchor and snapshots. Use `P` in a thread, or CLI `publish --summary`, to explicitly publish its selected draft as a PR-wide comment when inline coordinates do not apply. The preview never posts and requires confirmation in Neovim.

Receipts retain remote IDs and URLs. Stable hidden markers recover an existing comment after a successful POST with an uncertain response; keep those markers if retry recovery matters. Deleting a session discards local records but does not undo source changes or remote comments.

## Verification and limits

From the plugin checkout (`src/vim/local_plugins/review_session/` in these dotfiles):

```sh
python3 -m unittest discover -s tests -v
nvim --headless -u NONE -l tests/editor.lua
nvim --headless -u NONE -l tests/codediff.lua
nvim --headless -u NONE -l tests/codediff_symbolic.lua
nvim --headless -u NONE -l tests/codediff_session.lua
nvim --headless -u NONE -l tests/fugitive.lua
```

Lua checks derive their runtime and CLI paths from the test script, so they also work when invoked by path from another directory. The viewer tests use installed plugins; `CODEDIFF_RTP` and `FUGITIVE_RTP` override their paths. Python tests use temporary Git repositories, concurrent writers and mocked GitHub responses. No test posts to GitHub.

Fugitive has no canonical two-pane direction API. The adapter identifies actual endpoints; domain rules orient committed ancestors before descendants, then index before worktree, and unrelated commits by stable commit-ID order. Selecting either pane yields the same pair and an exact source side, independent of window geometry.

Large-repository performance and broad platform compatibility are unbenchmarked. Markdown thread views reload explicitly with `R`. Session format 2 implements this viewer-driven contract; unknown formats are rejected without rewriting their data. See [design](docs/design.md), [ADR](docs/adr/0001-viewer-driven-sessions.md), [glossary](CONTEXT.md), and `:help review-session`.

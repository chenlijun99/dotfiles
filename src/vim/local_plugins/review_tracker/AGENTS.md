# review_tracker — agent notes

## Purpose

Tracks which files have been reviewed during a local code-review session. A file is "reviewed"
when it has a language-appropriate `REVIEWED` comment prepended to it as an unstaged working-tree
change. The plugin is split into a standalone core and pluggable integrations; codediff.nvim is
the only integration so far.

## Non-obvious design decisions

### is_reviewed always reads from disk

`read_head` uses `vim.fn.readfile` unconditionally and never touches the neovim buffer, even when
the file is loaded. An earlier version preferred buffer contents, but that caused stale `true`
returns after `git reset --hard HEAD`: the disk file is reverted immediately, but the in-memory
buffer keeps the old content until neovim reloads it. Reading disk directly is always correct
because `set_reviewed` also writes to disk before scheduling a `checktime`.

### codediff integration: render hook, not buf_attach

`ensure_render_hooked` wraps `explorer.tree.render` in place rather than using
`nvim_buf_attach`/`on_lines`. The `on_lines` approach was tried first and failed: neovim does not
fire the callback when `nvim_buf_set_lines` produces content identical to what was already in the
buffer (same file count and names). This happens frequently when only the REVIEWED markers on disk
change — the explorer tree text is the same but the decoration needs to update. The render hook
fires unconditionally.

The hook is stored as `explorer._review_tracker_hooked` on the explorer table to prevent
double-wrapping if `CodeDiffFileSelect` fires more than once for the same session.

### commentstring detection uses a scratch buffer

`prefix_for_ft` creates a scratch buffer (`buftype=nofile`), sets its filetype, and reads
`vim.bo.commentstring`. This is needed for files not currently open in neovim. `buftype=nofile`
prevents LSP servers from attaching. Results are cached per filetype with `false` as the sentinel
for "filetype known but has no comment syntax" (to distinguish from an uncached `nil`).

### No prefix for unknown filetypes

`get_comment_prefix` returns `nil` when the filetype is genuinely unknown (no buffer, no
`vim.filetype.match` result, no extension match). `set_reviewed` then writes the bare string
`REVIEWED` with no comment wrapper. This is intentional — blocking the mark on unknown filetypes
was considered worse than writing a bare marker.

## codediff.nvim internals relied upon

The integration accesses these codediff internals — check them if codediff is upgraded:

* `lifecycle.get_explorer(tabpage)` → returns the explorer object or `nil`.
* `lifecycle.get_buffers(tabpage)` → returns `(original_bufnr, modified_bufnr)` for the two diff
  panes; used by `resolve_file` to detect when the current buffer is a diff pane.
* `explorer.tree:get_node(line_number)` → returns the node rendered at that 1-based line after
  the last `render()` call. File nodes have `node.data.path` (relative to `git_root`) and
  `node.data.type == nil`. Group/directory nodes have `node.data.type == "group"` or
  `"directory"`.
* `explorer.current_file_path` — relative path of the file currently open in the diff panes;
  tracked by codediff's actions module whenever a file is selected. Used by `resolve_file` to
  map a diff-pane buffer back to its working-tree file (important for the virtual/old-revision
  pane whose buffer name is a `codediff:///` URL, not a real path).
* `explorer.git_root` — absolute path; `nil` in directory-comparison mode (no git).
* `explorer.status_result` — `{ unstaged, staged, conflicts }` lists used by `:ReviewProgress`.
* `explorer.tree.render` — method on the tree instance (not the metatable); safe to wrap.
* The explorer buffer has `filetype = "codediff-explorer"`.
* Virtual (old-revision) diff buffers have `buftype = "nowrite"` and names of the form
  `codediff:///git_root///commit/filepath`. Real (working-tree) diff buffers are ordinary file
  buffers with `buftype = ""`.
* codediff's auto-refresh debounces `.git` watcher events by 500 ms before calling
  `M.refresh(explorer)`, which calls `explorer.tree:render()` — this is what our hook intercepts.

## Deployment

The plugin lives in `~/.vim/local_plugins/review_tracker/` (dotfiles deploy `src/vim/` →
`~/.vim/`). It is loaded by lazy.nvim via a `dir =` spec in
`src/vim/lua/clj/plugin/vcs/review_tracker.lua`, which is auto-discovered because the vcs
`init.lua` imports it. The lazy spec adds the directory to `runtimepath`, making
`require("review_tracker")` resolve to `lua/review_tracker/init.lua` inside the plugin dir.

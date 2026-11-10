-- Actual codediff: normal navigation is passive, explicit actions collect exact pairs.
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local viewer = vim.env.CODEDIFF_RTP or vim.fn.expand("~/.local/share/nvim/lazy/codediff.nvim")
assert(vim.fn.isdirectory(viewer) == 1, "set CODEDIFF_RTP to codediff.nvim")
vim.opt.runtimepath:append(viewer); vim.opt.runtimepath:append(plugin)
vim.cmd("runtime plugin/codediff.lua"); require("codediff").setup({})
local review = require("review_session")
local tmp = vim.fn.tempname(); vim.fn.mkdir(tmp .. "/repo", "p")
local repo, session = tmp .. "/repo", tmp .. "/session"
local function run(args) local r = vim.system(args, { text = true }):wait(); assert(r.code == 0, r.stderr); return vim.trim(r.stdout) end
local function git(...) return run(vim.list_extend({ "git", "-C", repo }, { ... })) end
local function cli(...) return vim.json.decode(run(vim.list_extend({ "python3", plugin .. "/bin/review-session", "--session", session }, { ... }))) end
local function wait(fn) assert(vim.wait(15000, fn, 20), "timed out") end
local function cache() return review.context() and review.context().cache end
local lc
local function open(...)
	local opened
	vim.api.nvim_create_autocmd("User", { pattern = "CodeDiffOpen", once = true, callback = function(event) opened = event.data.tabpage end })
	vim.api.nvim_cmd({ cmd = "CodeDiff", args = vim.list_extend({ "--repo", repo }, { ... }) }, {})
	wait(function() if not opened or vim.api.nvim_get_current_tabpage() ~= opened then return false end; local old, new = lc.get_buffers(opened); return old and new and cache() and not review.context().busy end)
end
local ok, err = xpcall(function()
	git("init", "-q"); git("config", "user.name", "Test"); git("config", "user.email", "test@example.com")
	vim.fn.writefile({ "A", "line" }, repo .. "/a.lua"); git("add", "."); git("commit", "-qm", "A")
	local a = git("rev-parse", "HEAD")
	vim.fn.writefile({ "B", "line" }, repo .. "/a.lua"); git("commit", "-qam", "B"); local b = git("rev-parse", "HEAD")
	vim.fn.writefile({ "C", "line" }, repo .. "/a.lua"); git("commit", "-qam", "C"); local c = git("rev-parse", "HEAD")
	cli("init", "--repo", repo)
	review.setup({ fugitive = false }); vim.cmd.edit(repo .. "/a.lua"); review.attach(session)
	wait(function() return cache() ~= nil end)
	local before = vim.fn.readblob(session .. "/session.sqlite3")
	lc = require("codediff.ui.lifecycle")
	open(b, c)
	assert(review.context().session == session, "normal viewer tab must inherit originating session")
	assert(cache().status.files[1].old_ref == b and cache().status.files[1].new_ref == c)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == before, "navigation must not enroll/snapshot/write")
	local old, new = lc.get_buffers(vim.api.nvim_get_current_tabpage())
	vim.api.nvim_set_current_buf(new); review.toggle(false)
	wait(function() return cache() and cache().status.reviewed == 1 end)
	vim.api.nvim_set_current_buf(old); review.create("range", 1, 1)
	wait(function() return vim.bo.buftype == "acwrite" end)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "B to C finding" }); vim.cmd.write()
	wait(function() return vim.b.review_thread ~= nil end)
	local id = vim.b.review_thread
	assert(cli("source", "--thread", id).text == "B\nline\n")
	open(a, b)
	assert(cache().status.files[1].reviewed == "another", "other pair must be a session-wide hint, not reviewed")
	local current = require("review_session.codediff").resolve(true)
	local threads = cli("threads", "--view-file", (function() local p = tmp .. "/view.json"; vim.fn.writefile({ vim.json.encode(current) }, p); return p end)())
	assert(#threads == 1 and threads[1].other_revision)
	review.open_thread(id)
	wait(function() return vim.b.review_thread == id end)
	local gc = lc.get_git_context(vim.api.nvim_get_current_tabpage())
	assert(gc.original_revision == b and gc.modified_revision == c, "other-revision thread must reopen original pair")
	-- Same path has distinct staged and unstaged rows; bulk includes collapsed data rows.
	vim.fn.writefile({ "staged", "line" }, repo .. "/a.lua"); git("add", "a.lua")
	vim.fn.writefile({ "working", "line" }, repo .. "/a.lua")
	vim.fn.mkdir(repo .. "/nested", "p"); vim.fn.writefile({ "new" }, repo .. "/nested/b.lua"); git("add", "nested/b.lua")
	local passive = vim.fn.readblob(session .. "/session.sqlite3")
	open()
	local all = require("review_session.codediff").resolve(true)
	assert(#all.files == 3, vim.inspect(all))
	assert(vim.fn.readblob(session .. "/session.sqlite3") == passive)
	local views = {}
	for _, file in ipairs(cache().status.files) do views[file.key] = file end
	assert(views["staged:a.lua"].old_ref == c and views["staged:a.lua"].new_ref == "INDEX:0")
	assert(views["unstaged:a.lua"].old_ref == "INDEX:0" and views["unstaged:a.lua"].new_ref == "WORKTREE")
	review.toggle(true)
	wait(function() return cache() and cache().status.reviewed == 3 end)
	-- Bulk/panel capture must reject targeted unsaved sources without saving or marking.
	local worktab = vim.api.nvim_get_current_tabpage()
	local workbuf = vim.fn.bufnr(repo .. "/a.lua")
	local panelbuf = lc.get_panel(worktab).view.bufnr
	vim.bo[workbuf].modifiable = true
	vim.api.nvim_buf_set_lines(workbuf, 0, 1, false, { "UNSAVED worktree edit" })
	vim.api.nvim_set_current_buf(panelbuf)
	local unchanged = vim.fn.readblob(session .. "/session.sqlite3")
	review.toggle(true)
	vim.wait(100, function() return false end)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == unchanged)
	local tree = lc.get_panel(worktab).view.tree
	for line = 1, vim.api.nvim_buf_line_count(panelbuf) do
		local node = tree:get_node(line)
		if node and node.data and node.data.path == "a.lua" and node.data.group == "unstaged" then vim.api.nvim_win_set_cursor(0, { line, 0 }); break end
	end
	review.create("file")
	vim.wait(100, function() return false end)
	assert(vim.api.nvim_get_current_buf() == panelbuf and vim.fn.readblob(session .. "/session.sqlite3") == unchanged)
	assert(vim.bo[workbuf].modified and vim.api.nvim_buf_get_lines(workbuf, 0, 1, false)[1] == "UNSAVED worktree edit")
	-- An unrelated committed pair of the same file does not target the unsaved worktree.
	open(b, c)
	local _, committednew = lc.get_buffers(vim.api.nvim_get_current_tabpage())
	vim.api.nvim_set_current_buf(committednew)
	review.toggle(false)
	wait(function() return cache() and cache().status.reviewed == 0 end)
	assert(vim.bo[workbuf].modified)
	vim.api.nvim_buf_set_lines(workbuf, 0, 1, false, { "working" }); vim.bo[workbuf].modified = false
	vim.api.nvim_set_current_tabpage(worktab)
	-- Mutable original pairs either use native supported syntax or exact snapshot fallback.
	local indexnote = cli("create", "--old", "INDEX", "--new", "WORKTREE", "--path", "a.lua", "--start", "1", "--body", "Index original")
	local worknote = cli("create", "--old", c, "--new", "WORKTREE", "--path", "a.lua", "--start", "1", "--body", "Commit/worktree original")
	local stagednote = cli("create", "--old", c, "--new", "INDEX", "--path", "a.lua", "--start", "1", "--body", "Staged original")
	open(a, b)
	review.open_thread(indexnote.id)
	wait(function() return vim.b.review_thread == indexnote.id end)
	local found_snapshot = false
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):find("/original/a.lua", 1, true) and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "working" then found_snapshot = true end
	end
	assert(found_snapshot, "unsupported index-to-worktree reopen must inspect original snapshots immediately")
	review.open_thread(worknote.id)
	wait(function() return vim.b.review_thread == worknote.id end)
	local opened = lc.get_git_context(vim.api.nvim_get_current_tabpage())
	assert(opened.original_revision == c and (opened.modified_revision == nil or opened.modified_revision == "WORKING"))
	review.open_thread(stagednote.id)
	wait(function() return vim.b.review_thread == stagednote.id end)
	opened = lc.get_git_context(vim.api.nvim_get_current_tabpage())
	assert(opened.original_revision == c and opened.modified_revision == ":0")

	-- A separate session in an existing tab keeps its own choice and cached source isolation.
	vim.api.nvim_set_current_tabpage(worktab)
	local firsttab, firstctx = vim.api.nvim_get_current_tabpage(), review.context()
	local second = tmp .. "/session2"
	run({ "python3", plugin .. "/bin/review-session", "--session", second, "init", "--repo", repo })
	vim.cmd("tabnew"); review.attach(second); open(b, c)
	local secondtab = vim.api.nvim_get_current_tabpage()
	assert(review.context().session == second and cache().status.reviewed == 0)
	vim.api.nvim_set_current_tabpage(firsttab)
	assert(review.context() == firstctx)
	vim.api.nvim_set_current_tabpage(secondtab)
	assert(review.context().session == second)
	local markns = vim.api.nvim_create_namespace("review_session_codediff")
	local old2 = lc.get_buffers(secondtab)
	assert(#vim.api.nvim_buf_get_extmarks(old2, markns, 0, -1, {}) == 0, "other session source annotations must not leak")
	vim.api.nvim_set_current_tabpage(firsttab)
	open(b, c)
	local markedtab, markedctx = vim.api.nvim_get_current_tabpage(), review.context()
	wait(function() return cache() and #cache().threads == 4 end)
	local markedold, markednew = lc.get_buffers(markedtab)
	assert(markedold == old2, "fixture must exercise actual shared committed source buffer")
	review.redraw()
	assert(#vim.api.nvim_buf_get_extmarks(markedold, markns, 0, -1, {}) == 1)
	vim.api.nvim_set_current_tabpage(secondtab)
	assert(#vim.api.nvim_buf_get_extmarks(old2, markns, 0, -1, {}) == 0,
		"empty session must clear shared source annotations synchronously on TabEnter")
	require("review_session.codediff").decorate(markedctx.cache)
	assert(#vim.api.nvim_buf_get_extmarks(old2, markns, 0, -1, {}) == 0, "inactive decoration callback must not paint")
	vim.api.nvim_set_current_tabpage(markedtab)
	assert(#vim.api.nvim_buf_get_extmarks(markedold, markns, 0, -1, {}) == 1,
		"switching back must restore original session's cached source mark before async reads")

	vim.api.nvim_set_current_tabpage(secondtab)
	local notices = #vim.api.nvim_get_autocmds({ event = "User", pattern = "CodeDiffFileSelect" })
	vim.api.nvim_create_user_command("CodeDiff", function() end, { nargs = "*", force = true })
	local defer = vim.defer_fn
	vim.defer_fn = function(fn, timeout) return defer(fn, timeout == 5000 and 50 or timeout) end
	markedctx.cache = nil
	review.open_thread(id, markedctx)
	wait(function() return vim.b.review_thread == id end)
	vim.defer_fn = defer
	assert(#vim.api.nvim_get_autocmds({ event = "User", pattern = "CodeDiffFileSelect" }) == notices,
		"failed async opening must remove pending selection hooks after snapshot fallback")

end, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then error(err) end
print("review_session codediff navigation checks passed")
vim.cmd("qa!")

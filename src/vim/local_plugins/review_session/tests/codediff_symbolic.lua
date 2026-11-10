-- Actual symbolic explorer/history refs stay pinned to displayed versions until viewer refresh.
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local viewer = vim.env.CODEDIFF_RTP or vim.fn.expand("~/.local/share/nvim/lazy/codediff.nvim")
assert(vim.fn.isdirectory(viewer) == 1, "set CODEDIFF_RTP to codediff.nvim")
vim.opt.runtimepath:append(viewer); vim.opt.runtimepath:append(plugin)
vim.cmd("runtime plugin/codediff.lua"); require("codediff").setup({})
local review = require("review_session")
local lc = require("codediff.ui.lifecycle")
local tmp = vim.fn.tempname(); vim.fn.mkdir(tmp .. "/repo/nested", "p")
local repo, session = tmp .. "/repo", tmp .. "/session"
local function run(args) local r = vim.system(args, { text = true }):wait(); assert(r.code == 0, r.stderr); return vim.trim(r.stdout) end
local function git(...) return run(vim.list_extend({ "git", "-C", repo }, { ... })) end
local function cli(...) return vim.json.decode(run(vim.list_extend({ "python3", plugin .. "/bin/review-session", "--session", session }, { ... }))) end
local function wait(fn) assert(vim.wait(15000, fn, 20), "timed out") end
local function commit(label)
	vim.fn.writefile({ label .. " a" }, repo .. "/a.lua")
	vim.fn.writefile({ label .. " b" }, repo .. "/nested/b.lua")
	git("add", "."); git("commit", "-qm", label)
	return git("rev-parse", "HEAD")
end
local function open(args, old, new)
	local opened
	vim.api.nvim_create_autocmd("User", { pattern = "CodeDiffOpen", once = true, callback = function(event) opened = event.data.tabpage end })
	vim.api.nvim_cmd({ cmd = "CodeDiff", args = vim.list_extend({ "--repo", repo }, args) }, {})
	wait(function()
		local context = opened and lc.get_git_context(opened)
		return context and context.original_revision == old and context.modified_revision == new and review.context(opened)
	end)
	local panel = lc.get_panel(opened)
	-- Stop only this fixture's watcher: the branch advance must precede a viewer refresh.
	local controller = lc.get_session(opened).refresh
	wait(function() return not controller.running and not controller.loading end)
	controller.timer:stop(); controller.poll:stop()
	if controller.unsubscribe then controller.unsubscribe(); controller.unsubscribe = nil end
	controller.request = function() end
	controller.schedule = function() end
	vim.api.nvim_set_current_buf(panel.view.bufnr)
	for line = 1, vim.api.nvim_buf_line_count(panel.view.bufnr) do
		local node = panel.view.tree:get_node(line)
		if node and node.data and node.data.path == "a.lua" then vim.api.nvim_win_set_cursor(0, { line, 0 }); break end
	end
	return opened, panel
end
local function capture(expected_old, expected_new, label)
	local descriptor = assert(require("review_session.codediff").resolve(false))
	assert(descriptor.files[1].old == expected_old and descriptor.files[1].new == expected_new, vim.inspect(descriptor))
	local all = assert(require("review_session.codediff").resolve(true))
	assert(#all.files == 2)
	for _, file in ipairs(all.files) do assert(file.old == expected_old and file.new == expected_new, vim.inspect(file)) end
	review.create("file")
	wait(function() return vim.bo.buftype == "acwrite" end)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { label }); vim.cmd.write()
	wait(function() return vim.b.review_thread ~= nil end)
	local anchor = cli("show", "--thread", vim.b.review_thread).thread.anchor
	assert(anchor.old_ref == expected_old and anchor.new_ref == expected_new)
	review.toggle(true)
	wait(function() return review.context().cache and review.context().cache.status.reviewed == 2 end)
	local pairs = cli("history")
	local matched = 0
	for _, pair in ipairs(pairs) do if pair.old_ref == expected_old and pair.new_ref == expected_new then matched = matched + 1 end end
	assert(matched == 2, "bulk must mark both displayed pairs, including the unselected nested file")
end
local ok, err = xpcall(function()
	git("init", "-q"); git("config", "user.name", "Test"); git("config", "user.email", "test@example.com")
	commit("A"); local b, c = commit("B"), commit("C")
	cli("init", "--repo", repo)
	review.setup({ fugitive = false }); vim.cmd.edit(repo .. "/a.lua"); review.attach(session)
	local tab, panel = open({ "HEAD~1", "HEAD" }, b, c)
	local data = panel.view.data
	assert(data.source_revisions.original == "HEAD~1" and data.source_revisions.modified == "HEAD")
	local before = vim.fn.readblob(session .. "/session.sqlite3")
	local d = commit("D")
	assert(lc.get_git_context(tab).original_revision == b and lc.get_git_context(tab).modified_revision == c)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == before, "branch navigation must not write the session")
	capture(b, c, "Displayed B/C explorer finding")
	assert(data.source_revisions.original == "HEAD~1" and data.source_revisions.modified == "HEAD", "capture must not mutate viewer refresh dependencies")
	-- History also retains its resolved displayed base rather than re-resolving a moving symbolic option.
	open({ "history", "--base", "HEAD~2" }, b, d)
	commit("E")
	capture(b, d, "Displayed B/D history finding")
end, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then error(err) end
print("review_session symbolic CodeDiff endpoint checks passed")
vim.cmd("qa!")

-- Actual Fugitive: exact native partners and current staged/unstaged status section.
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local viewer = vim.env.FUGITIVE_RTP or vim.fn.expand("~/.local/share/nvim/plugins/vim-fugitive")
assert(vim.fn.isdirectory(viewer) == 1, "set FUGITIVE_RTP to vim-fugitive")
vim.opt.runtimepath:append(viewer); vim.opt.runtimepath:append(plugin)
vim.cmd("runtime plugin/fugitive.vim")
local review = require("review_session")
local tmp = vim.fn.tempname(); vim.fn.mkdir(tmp .. "/repo", "p")
local repo, session = tmp .. "/repo", tmp .. "/session"
local function run(args) local r = vim.system(args, { text = true }):wait(); assert(r.code == 0, r.stderr); return vim.trim(r.stdout) end
local function git(...) return run(vim.list_extend({ "git", "-C", repo }, { ... })) end
local function cli(...) return vim.json.decode(run(vim.list_extend({ "python3", plugin .. "/bin/review-session", "--session", session }, { ... }))) end
local function wait(fn) assert(vim.wait(15000, fn, 20), "timed out") end
local function cache() return review.context() and review.context().cache end
local ok, err = xpcall(function()
	git("init", "-q"); git("config", "user.name", "Test"); git("config", "user.email", "test@example.com")
	vim.fn.writefile({ "HEAD", "line" }, repo .. "/a.lua"); vim.fn.writefile({ "unique rename content" }, repo .. "/rename_old.lua"); git("add", "."); git("commit", "-qm", "base")
	local head = git("rev-parse", "HEAD")
	vim.fn.writefile({ "INDEX", "line" }, repo .. "/a.lua"); git("add", "a.lua")
	vim.fn.writefile({ "WORKTREE", "line" }, repo .. "/a.lua")
	cli("init", "--repo", repo)
	review.setup({ codediff = false, viewer = "fugitive" }); vim.cmd.edit(repo .. "/a.lua"); review.attach(session)
	wait(function() return cache() ~= nil end)
	local passive = vim.fn.readblob(session .. "/session.sqlite3")
	vim.cmd("Gdiffsplit")
	wait(function() return cache() and cache().descriptor.viewer == "fugitive" and not review.context().busy end)
	local view, error, active = require("review_session.fugitive").resolve(false)
	assert(active and view, error)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == passive, "native diff navigation must be passive")
	local file = cache().status.files[1]
	assert(file.old_ref == "INDEX:0" and file.new_ref == "WORKTREE", vim.inspect(file))
	local windows = vim.api.nvim_tabpage_list_wins(0)
	local firstwin, otherwin = vim.api.nvim_get_current_win(), nil
	for _, win in ipairs(windows) do if win ~= firstwin and vim.wo[win].diff then otherwin = win end end
	assert(otherwin)
	review.toggle(false)
	wait(function() return cache() and cache().status.reviewed == 1 end)
	vim.api.nvim_set_current_win(otherwin)
	review.refresh(); wait(function() return cache() and not review.context().busy end)
	assert(cache().status.files[1].fingerprint == file.fingerprint, "both panes must identify same pair")
	review.create("range", 1, 1)
	wait(function() return vim.bo.buftype == "acwrite" end)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Index/worktree finding" }); vim.cmd.write()
	wait(function() return vim.b.review_thread ~= nil end)
	local id = vim.b.review_thread
	assert(cli("source", "--thread", id, "--side", "old").text == "INDEX\nline\n")
	assert(cli("source", "--thread", id, "--side", "new").text == "WORKTREE\nline\n")
	-- A third actual diff window is rejected, with source buffers retained.
	vim.api.nvim_set_current_win(firstwin)
	vim.cmd("vsplit"); vim.wo.diff = true
	local invalid, action_error = require("review_session.fugitive").resolve(false)
	assert(not invalid and action_error:find("three-way", 1, true))
	vim.cmd("close")
	-- Status bulk considers exactly the current section, including duplicate path rows.
	vim.cmd("diffoff!"); vim.cmd("only!"); vim.cmd.edit(repo .. "/a.lua"); vim.cmd("Git")
	wait(function() return type(vim.b.fugitive_status) == "table" end)
	local statusbuf = vim.api.nvim_get_current_buf()
	local function row(section, path)
		local active_section
		for line, text in ipairs(vim.api.nvim_buf_get_lines(statusbuf, 0, -1, false)) do
			local h = text:match("^(%u%l+).- %(%d+%+?%)$"); if h then active_section = h end
			if active_section == section and text == "M " .. path then vim.api.nvim_win_set_cursor(0, { line, 0 }); return end
		end
		error("missing status row " .. section)
	end
	row("Staged", "a.lua")
	view = require("review_session.fugitive").resolve(true)
	assert(#view.files == 1 and view.files[1].old == "HEAD" and view.files[1].new == "INDEX:0")
	local after_actions = vim.fn.readblob(session .. "/session.sqlite3")
	review.refresh(); wait(function() return cache() and cache().status.files[1].old_ref == head end)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == after_actions)
	local workbuf = vim.fn.bufnr(repo .. "/a.lua")
	vim.api.nvim_buf_set_lines(workbuf, 0, 1, false, { "UNSAVED worktree source" })
	assert(vim.bo[workbuf].modified)
	-- Staged HEAD:index does not target an unrelated unsaved worktree endpoint.
	review.toggle(true); wait(function() return cache() and cache().status.reviewed == 1 end)
	assert(vim.bo[workbuf].modified)
	row("Unstaged", "a.lua")
	view = require("review_session.fugitive").resolve(true)
	assert(#view.files == 1 and view.files[1].old == "INDEX:0" and view.files[1].new == "WORKTREE")
	local unchanged = vim.fn.readblob(session .. "/session.sqlite3")
	review.toggle(true); review.create("file")
	vim.wait(100, function() return false end)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == unchanged and vim.api.nvim_get_current_buf() == statusbuf,
		"unstaged status actions must reject a targeted unsaved working buffer")
	assert(vim.api.nvim_buf_get_lines(workbuf, 0, 1, false)[1] == "UNSAVED worktree source" and vim.bo[workbuf].modified)
	vim.api.nvim_buf_set_lines(workbuf, 0, 1, false, { "WORKTREE" }); vim.bo[workbuf].modified = false
	row("Staged", "a.lua")
	local indexurl = vim.fn.FugitiveFind(":0:a.lua", vim.fn.FugitiveGitDir(statusbuf))
	local indexbuf = vim.fn.bufadd(indexurl); vim.fn.bufload(indexbuf)
	vim.bo[indexbuf].modifiable = true
	vim.api.nvim_buf_set_lines(indexbuf, 0, 1, false, { "UNSAVED index source" })
	unchanged = vim.fn.readblob(session .. "/session.sqlite3")
	review.toggle(false)
	vim.wait(100, function() return false end)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == unchanged and vim.bo[indexbuf].modified,
		"staged status action must preserve an unsaved actual index endpoint")
	vim.api.nvim_buf_set_lines(indexbuf, 0, 1, false, { "INDEX" }); vim.bo[indexbuf].modified = false

	-- An unmodified virtual index buffer can lag behind an external index update.
	vim.fn.writefile({ "external index source", "line" }, repo .. "/a.lua"); git("add", "a.lua")
	vim.fn.writefile({ "WORKTREE", "line" }, repo .. "/a.lua")
	assert(not vim.bo[indexbuf].modified and vim.api.nvim_buf_get_lines(indexbuf, 0, 1, false)[1] == "INDEX")
	local notice, notify = nil, vim.notify
	vim.notify = function(message, level) notice = message; notify(message, level) end
	unchanged = vim.fn.readblob(session .. "/session.sqlite3")
	review.toggle(false)
	wait(function() return notice and notice:find("reload", 1, true) end)
	notice = nil
	review.create("file")
	wait(function() return notice and notice:find("reload", 1, true) end)
	assert(vim.api.nvim_get_current_buf() == statusbuf and vim.fn.readblob(session .. "/session.sqlite3") == unchanged)
	assert(not vim.bo[indexbuf].modified and vim.api.nvim_buf_get_lines(indexbuf, 0, 1, false)[1] == "INDEX", "stale index buffer must not be saved over new index content")
	vim.notify = notify
	vim.fn.writefile({ "INDEX", "line" }, repo .. "/a.lua"); git("add", "a.lua")
	vim.fn.writefile({ "WORKTREE", "line" }, repo .. "/a.lua")

	-- Native index buffers retain read-format metadata for matching CRLF/no-final-newline blobs.
	for _, sample in ipairs({ { path = "index-no-final.lua", lines = { "index without final newline" }, binary = true, format = "unix", eol = false },
		{ path = "index-crlf.lua", lines = { "index one\r", "index two\r" }, format = "dos", eol = true } }) do
		vim.fn.writefile(sample.lines, repo .. "/" .. sample.path, sample.binary and "b" or "")
		git("add", sample.path)
		local url = vim.fn.FugitiveFind(":0:" .. sample.path, vim.fn.FugitiveGitDir(statusbuf))
		local buf = vim.fn.bufadd(url); vim.fn.bufload(buf)
		assert(vim.bo[buf].fileformat == sample.format and vim.bo[buf].endofline == sample.eol)
		vim.cmd("Git")
		for line, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
			if text == "A " .. sample.path then vim.api.nvim_win_set_cursor(0, { line, 0 }); break end
		end
		review.toggle(false)
		wait(function()
			local pairs = cli("history", "--old", "HEAD", "--new", "INDEX", "--path", sample.path)
			return #pairs == 1
		end)
	end

	git("mv", "rename_old.lua", "rename_new.lua"); vim.cmd("Git")
	wait(function() return vim.b.fugitive_status.files.Staged["rename_old.lua -> rename_new.lua"] ~= nil end)
	for line, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		if text == "R rename_old.lua -> rename_new.lua" then vim.api.nvim_win_set_cursor(0, { line, 0 }) end
	end
	local renamed = require("review_session.fugitive").resolve(false).files[1]
	assert(renamed.old_path == "rename_old.lua" and renamed.new_path == "rename_new.lua", "status rename endpoint order must follow actual Fugitive records")

	-- Opening a historical thread through preferred Fugitive retains its native exact partners.
	review.open_thread(id)
	wait(function() return vim.b.review_thread == id end)
	local anchor = cli("show", "--thread", id).thread.anchor
	assert(anchor.old_ref == "INDEX:0" and anchor.new_ref == "WORKTREE")
	git("add", "a.lua"); git("commit", "-qm", "next historical commit")
	local nextcommit = git("rev-parse", "HEAD")
	vim.cmd("diffoff!"); vim.cmd("only!")
	local before_history = vim.fn.readblob(session .. "/session.sqlite3")
	vim.cmd.edit(repo .. "/a.lua")
	vim.api.nvim_cmd({ cmd = "Gtabedit", args = { nextcommit .. ":a.lua" } }, {})
	vim.api.nvim_cmd({ cmd = "Gdiffsplit", args = { head .. ":a.lua" } }, {})
	wait(function() return cache() and cache().status.files[1].old_ref == head and cache().status.files[1].new_ref == nextcommit end)
	assert(review.context().session == session, "new native Fugitive viewer tab must inherit originating session")
	assert(vim.fn.readblob(session .. "/session.sqlite3") == before_history, "historical navigation must not write session")

end, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then error(err) end
print("review_session Fugitive navigation checks passed")
vim.cmd("qa!")

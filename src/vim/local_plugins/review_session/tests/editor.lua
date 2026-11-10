-- Ordinary-buffer integration with no optional viewers installed.
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:append(plugin)
local review = require("review_session")
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp .. "/repo", "p")
local repo, session = tmp .. "/repo", tmp .. "/session"
local function run(args)
	local r = vim.system(args, { text = true }):wait()
	assert(r.code == 0, r.stderr)
	return vim.trim(r.stdout)
end
local function git(...) return run(vim.list_extend({ "git", "-C", repo }, { ... })) end
local function cli(...) return vim.json.decode(run(vim.list_extend({ "python3", plugin .. "/bin/review-session", "--session", session }, { ... }))) end
local function wait(fn) assert(vim.wait(15000, fn, 20), "timed out") end
local ok, err = xpcall(function()
	git("init", "-q"); git("config", "user.name", "Test"); git("config", "user.email", "test@example.com")
	vim.fn.writefile({ "old", "line" }, repo .. "/a.lua"); git("add", "."); git("commit", "-qm", "base")
	vim.fn.writefile({ "new", "line" }, repo .. "/a.lua")
	cli("init", "--repo", repo)
	review.setup({ codediff = false, fugitive = false })
	vim.cmd.edit(repo .. "/a.lua")
	local sourcebuf, sourcetab = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_tabpage()
	local db = vim.fn.readblob(session .. "/session.sqlite3")
	review.attach(session)
	wait(function() return review.context() and review.context().cache ~= nil end)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == db, "passive attach must not write")
	assert(package.loaded["codediff.ui.lifecycle"] == nil)
	review.toggle(false)
	wait(function() return review.context().cache and review.context().cache.status.reviewed == 1 end)
	-- Matching saved formats must pass without normalizing the captured source bytes.
	for _, sample in ipairs({ { path = "no-final.lua", lines = { "no final newline" }, binary = true, format = "unix", eol = false },
		{ path = "crlf.lua", lines = { "one\r", "two\r" }, format = "dos", eol = true } }) do
		vim.fn.writefile(sample.lines, repo .. "/" .. sample.path, sample.binary and "b" or "")
		vim.cmd.edit(repo .. "/" .. sample.path)
		assert(vim.bo.fileformat == sample.format and vim.bo.endofline == sample.eol)
		review.toggle(false)
		wait(function() return review.context().cache and review.context().cache.status.files[1].path == sample.path and review.context().cache.status.reviewed == 1 end)
	end
	vim.cmd.edit(repo .. "/a.lua")
	wait(function() return review.context().cache and review.context().cache.status.files[1].path == "a.lua" end)

	-- External writes can leave an unmodified displayed source stale before selection.
	local selected_text = vim.api.nvim_buf_get_lines(sourcebuf, 0, -1, false)
	vim.fn.writefile({ "external saved version", "line" }, repo .. "/a.lua")
	assert(not vim.bo[sourcebuf].modified and vim.deep_equal(vim.api.nvim_buf_get_lines(sourcebuf, 0, -1, false), selected_text))
	local unchanged, notice, notify = vim.fn.readblob(session .. "/session.sqlite3"), nil, vim.notify
	vim.notify = function(message, level) notice = message; notify(message, level) end
	review.create("range", 1, 1)
	wait(function() return notice and notice:find("reload", 1, true) end)
	assert(vim.api.nvim_get_current_buf() == sourcebuf and #cli("threads") == 0)
	notice = nil
	review.toggle(false)
	wait(function() return notice and notice:find("reload", 1, true) end)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == unchanged and not vim.bo[sourcebuf].modified)
	assert(vim.deep_equal(vim.api.nvim_buf_get_lines(sourcebuf, 0, -1, false), selected_text), "stale source must not be saved or rewritten")
	vim.notify = notify
	vim.fn.writefile({ "new", "line" }, repo .. "/a.lua")

	review.create("range", 1, 2)
	wait(function() return vim.bo.buftype == "acwrite" end)
	local editbuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(editbuf, 0, -1, false, { "Why this change?" })
	local notification, notify = nil, vim.notify
	vim.notify = function(message, level) notification = message; notify(message, level) end
	vim.fn.writefile({ "concurrent change", "line" }, repo .. "/a.lua")
	vim.cmd.write()
	wait(function() return notification and (notification:find("source changed", 1, true) or notification:find("displayed source", 1, true)) end)
	assert(vim.bo[editbuf].modified and #cli("threads") == 0)
	vim.fn.writefile({ "new", "line" }, repo .. "/a.lua")
	vim.notify = notify
	vim.cmd.write()
	wait(function() return vim.b.review_thread ~= nil end)
	local id = vim.b.review_thread
	assert(cli("source", "--thread", id, "--side", "old").text == "old\nline\n")
	vim.api.nvim_set_current_buf(editbuf)
	vim.api.nvim_buf_set_lines(editbuf, 0, -1, false, { "Edited question" }); vim.cmd.write()
	wait(function() return not vim.bo[editbuf].modified end)
	assert(#cli("threads") == 1 and cli("show", "--thread", id).thread.messages[1].body == "Edited question")
	vim.api.nvim_set_current_buf(sourcebuf)
	review.refresh()
	wait(function() return review.context().cache and #review.context().cache.threads == 1 end)
	local ns = vim.api.nvim_create_namespace("review_session")
	local function marks() return #vim.api.nvim_buf_get_extmarks(sourcebuf, ns, 0, -1, {}) end
	review.redraw(); assert(marks() == 1)
	vim.cmd("tabnew")
	assert(marks() == 0, "plain no-context tab must clear immediately")
	review.attach(tmp .. "/missing")
	assert(marks() == 0)
	vim.api.nvim_set_current_tabpage(sourcetab)
	assert(marks() == 1, "tab switch must restore own cached annotations synchronously")
	review.open_source(id)
	wait(function() return vim.api.nvim_buf_get_name(0):find("/source/", 1, true) ~= nil end)
	assert(not vim.bo.modifiable and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "new")
	local picker, original_select = nil, vim.ui.select
	vim.ui.select = function(items, _, callback) picker = items; callback(nil) end
	review.pick(true)
	wait(function() return picker ~= nil end)
	assert(#picker == 1, "session-wide picker must work without a current file view")
	vim.ui.select = original_select
	-- No Git objects are needed to reopen the original immutable snapshot.
	vim.fn.rename(repo, tmp .. "/gone")
	review.context().cache = nil
	review.open_thread(id)
	wait(function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_get_name(buf):find("/original/a.lua", 1, true) then
				return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "new" and vim.b.review_thread == id
			end
		end
	end)
	vim.api.nvim_buf_set_lines(sourcebuf, 0, 1, false, { "UNSAVED unrelated source" })
	review.create("review")
	wait(function() return vim.bo.buftype == "acwrite" end)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Review-wide note with no source view" }); vim.cmd.write()
	wait(function() return #cli("threads") == 2 end)
	assert(vim.bo[sourcebuf].modified and vim.api.nvim_buf_get_lines(sourcebuf, 0, 1, false)[1] == "UNSAVED unrelated source")

end, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then error(err) end
print("review_session ordinary editor checks passed")
vim.cmd("qa!")

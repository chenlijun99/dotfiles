-- Missing/deleted workspaces unload once; ordinary viewer navigation stays passive and quiet.
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local viewer = vim.env.CODEDIFF_RTP or vim.fn.expand("~/.local/share/nvim/lazy/codediff.nvim")
assert(vim.fn.isdirectory(viewer) == 1, "set CODEDIFF_RTP to codediff.nvim")
vim.opt.runtimepath:append(plugin); vim.opt.runtimepath:append(viewer)
vim.cmd("runtime plugin/codediff.lua"); require("codediff").setup({})
local review, lc = require("review_session"), require("codediff.ui.lifecycle")
local tmp = vim.fn.tempname(); vim.fn.mkdir(tmp .. "/repo", "p")
local repo, session = tmp .. "/repo", tmp .. "/session"
local notifications, calls, running, source_failure = {}, {}, 0, false
local hold_missing, hold_load, missing_responses, load_responses = false, false, {}, {}
local system, notify = vim.system, vim.notify
vim.notify = function(message, ...)
	if message:find("review_session:", 1, true) then notifications[#notifications + 1] = message else notify(message, ...) end
end
vim.system = function(args, opts, callback)
	if vim.tbl_contains(args, "--session") then
		calls[#calls + 1] = args[5]
		running = running + 1
		local function finish(result)
			running = running - 1
			local function deliver() callback(result) end
			if hold_missing and result.code ~= 0 and result.stderr:find("missing_session", 1, true) then missing_responses[#missing_responses + 1] = deliver
			elseif hold_load and args[5] == "load" and result.code == 0 then load_responses[#load_responses + 1] = deliver
			else deliver() end
		end
		if source_failure and args[5] == "view" then
			vim.schedule(function() finish({ code = 1, stdout = "", stderr = '{"error":"invalid Git revision"}' }) end)
			return {}
		end
		return system(args, opts, finish)
	end
	return system(args, opts, callback)
end
local function run(args) local r = system(args, { text = true }):wait(); assert(r.code == 0, r.stderr); return vim.trim(r.stdout) end
local function git(...) return run(vim.list_extend({ "git", "-C", repo }, { ... })) end
local function wait(fn) assert(vim.wait(10000, fn, 20), "timed out") end
local function settle()
	vim.wait(200, function() return false end)
	wait(function() return running == 0 and (not review.context() or not review.context().busy) end)
	vim.wait(50, function() return false end)
end
local function navigate()
	for _ = 1, 4 do vim.api.nvim_exec_autocmds("User", { pattern = "CodeDiffFileSelect" }) end
	settle()
end
local function open(base)
	local opened
	vim.api.nvim_create_autocmd("User", { pattern = "CodeDiffOpen", once = true, callback = function(event) opened = event.data.tabpage end })
	vim.api.nvim_cmd({ cmd = "CodeDiff", args = { "--repo", repo, base, "HEAD" } }, {})
	wait(function() if not opened then return false end; local old, new = lc.get_buffers(opened); return old and new end)
	settle()
	return opened
end
local ok, err = xpcall(function()
	git("init", "-q"); git("config", "user.name", "Test"); git("config", "user.email", "test@example.com")
	vim.fn.writefile({ "old" }, repo .. "/a.lua"); git("add", "."); git("commit", "-qm", "base")
	local base = git("rev-parse", "HEAD")
	vim.fn.writefile({ "new" }, repo .. "/a.lua"); git("commit", "-qam", "head")
	review.setup({ fugitive = false }); vim.cmd.edit(repo .. "/a.lua")
	open(base); navigate()
	assert(not review.context() and #calls == 0 and #notifications == 0, "fresh no-session navigation must not query or notify")
	-- The load check runs even without a source view, and pending invalid loads cannot be inherited.
	vim.cmd("tabnew")
	review.attach(tmp .. "/missing")
	assert(not review.context(), "unvalidated workspace must not be selected")
	open(base)
	assert(not review.context() and #calls == 1 and calls[1] == "load" and #notifications == 1)
	assert(not vim.uv.fs_stat(tmp .. "/missing"), "loading must not create a missing workspace")
	calls, notifications = {}, {}
	navigate(); open(base); navigate()
	assert(not review.context() and #calls == 0 and #notifications == 0, "failed-load selection must not persist or inherit")
	-- A valid load is read-only; normal new viewer tabs still inherit it.
	run({ "python3", plugin .. "/bin/review-session", "--session", session, "init", "--repo", repo })
	local before = vim.fn.readblob(session .. "/session.sqlite3")
	review.attach(session)
	wait(function() return review.context() and review.context().cache end); settle()
	local parent = vim.api.nvim_get_current_tabpage()
	local child = open(base)
	assert(review.context().session == session and review.context(parent).session == session)
	assert(vim.fn.readblob(session .. "/session.sqlite3") == before, "load/navigation must not write session storage")
	-- Source errors retain the valid workspace, rather than being mistaken for deletion.
	source_failure = true
	local selected = review.context()
	review.refresh(); settle()
	assert(review.context() == selected and notifications[#notifications]:find("invalid Git revision", 1, true))
	source_failure = false; navigate()
	assert(review.context() == selected and review.context().cache)
	calls, notifications = {}, {}
	vim.fn.delete(session, "rf")
	navigate()
	assert(#calls == 1 and calls[1] == "view", "deleted selection must stop after its first missing-session response")
	assert(not review.context(child) and not review.context(parent) and #notifications == 0, "passive deletion unloads selection and inheritance quietly")
	calls, notifications = {}, {}
	navigate(); open(base); navigate()
	assert(not review.context() and #calls == 0 and #notifications == 0, "navigation after deletion must not retry or inherit")
	review.toggle(false)
	assert(#calls == 0 and #notifications == 1 and notifications[1]:find("ReviewSession", 1, true), "explicit review action still needs a helpful load prompt")
	-- Hold real CLI responses to exercise both callback orders during same-path replacement.
	local function init() run({ "python3", plugin .. "/bin/review-session", "--session", session, "init", "--repo", repo }) end
	local function deliver(responses) for _, callback in ipairs(responses) do callback() end end
	init(); review.attach(session)
	wait(function() return review.context() and review.context().cache end); settle()
	local old_parent = vim.api.nvim_get_current_tabpage()
	open(base)
	local old = review.context()
	vim.fn.delete(session, "rf")
	hold_missing = true
	review.refresh()
	wait(function() return #missing_responses == 1 end)
	assert(review.context() == old, "real missing read response must still be held")
	init(); review.attach(session)
	wait(function() return review.context() and review.context() ~= old and review.context().cache end); settle()
	local replacement_parent, replacement = vim.api.nvim_get_current_tabpage(), review.context()
	open(base)
	local replacement_child = review.context()
	hold_missing = false; deliver(missing_responses); missing_responses = {}; settle()
	assert(review.context() == replacement_child and review.context(replacement_parent) == replacement,
		"old missing read must preserve a later same-path selection and its inherited child")
	assert(old.invalid and not review.context(old_parent), "only the initiating generation and its inherited parent must be cleared")
	assert(not replacement.invalid and not replacement_child.invalid)
	notifications = {}; navigate(); open(base)
	assert(review.context() and #notifications == 0, "replacement must keep inheriting and navigating without obsolete missing errors")
	-- Deliver an old missing LOAD before a newer real successful LOAD is delivered.
	vim.fn.delete(session, "rf")
	hold_missing = true; review.attach(session)
	wait(function() return #missing_responses == 1 end)
	init(); hold_load = true; review.attach(session)
	wait(function() return #load_responses == 1 end)
	assert(not review.context(), "new successful load is pending validation delivery")
	hold_missing = false; deliver(missing_responses); missing_responses = {}; settle()
	assert(not review.context(), "obsolete missing load must not install a selection")
	hold_load = false; deliver(load_responses); load_responses = {}
	wait(function() return review.context() and review.context().cache end); settle()
	local validated = review.context()
	assert(not validated.invalid and validated.session == session, "obsolete failure must not cancel the newer pending load")
	notifications = {}; navigate(); open(base)
	assert(review.context() and not review.context().invalid and #notifications == 0)

end, debug.traceback)
vim.system, vim.notify = system, notify
vim.fn.delete(tmp, "rf")
if not ok then error(err) end
print("review_session missing/deleted workspace checks passed")
vim.cmd("qa!")

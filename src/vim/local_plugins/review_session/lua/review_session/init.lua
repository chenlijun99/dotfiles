---@class ReviewSessionOptions
---@field python? string Python 3.10+ interpreter
---@field cli? string Bundled Python script override
---@field codediff? boolean Enable codediff adapter (default true)
---@field fugitive? boolean Enable Fugitive adapter (default true)
---@field viewer? string|fun(anchor: table, done: fun(), failed: fun()): boolean Preferred original-context viewer (default codediff)
---@field keys? boolean Install default reviewed mappings
---@class ReviewSessionContext
---@field session string
---@field cache? table Cached read-only view status and visible threads
---@field busy? boolean
---@field again? boolean
local M = {}
local contexts, origins = {}, {}
local leaving
local options = {}
local ns = vim.api.nvim_create_namespace("review_session")
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))))
local function notify(message, level) vim.notify("review_session: " .. message, level or vim.log.levels.INFO) end
local function adapter(name)
	if options[name] == false then return end
	return require("review_session." .. name)
end
---@param tab? integer
---@return ReviewSessionContext|nil
function M.context(tab) return contexts[tab or vim.api.nvim_get_current_tabpage()] end

---@param ctx ReviewSessionContext
---@param operation string
---@param args table
---@param callback fun(result: any)
---@param failed? fun()
function M.request(ctx, operation, args, callback, failed)
	vim.system({ options.python or "python3", options.cli or root .. "/bin/review-session", "--session", ctx.session, operation, "--request-file", "-" },
		{ text = true, stdin = vim.json.encode(vim.tbl_extend("force", { role = "human" }, args)) }, function(result)
			vim.schedule(function()
				local ok, value = pcall(vim.json.decode, result.stdout or "")
				if result.code ~= 0 or not ok then
					notify(result.stderr ~= "" and result.stderr or "invalid CLI response", vim.log.levels.ERROR)
					if failed then failed() end
					return
				end
				callback(value)
			end)
		end)
end

local function ref_name(ref)
	if ref == nil or ref == "WORKING" then return "WORKTREE" end
	if ref == "INDEX" then return "INDEX:0" end
	return ref:gsub("^:([0-3]):?$", "INDEX:%1")
end

--- Identify loaded buffers for exactly the endpoints targeted by an explicit action.
local function loaded_endpoints(view)
	local matches = {}
	if not view or not view.repo or not view.files then return matches end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local point
			for _, name in ipairs({ "codediff", "fugitive" }) do
				local viewer = adapter(name)
				if viewer and viewer.endpoint then point = viewer.endpoint(buf); if point then break end end
			end
			if not point and vim.bo[buf].buftype == "" then
				local filename = vim.api.nvim_buf_get_name(buf)
				if filename:sub(1, #view.repo + 1) == view.repo .. "/" then point = { repo = view.repo, path = filename:sub(#view.repo + 2), ref = "WORKTREE" } end
			end
			if point and point.repo == view.repo then
				local targeted = false
				for _, file in ipairs(view.files) do
					for _, side in ipairs({ "old", "new" }) do
						local ref = ref_name(file[side] or view[side])
						local relative = file[side .. "_path"]
						if not relative and (ref == "WORKTREE" or ref:match("^INDEX:")) then relative = file[side .. "_probe_path"] or file[(side == "old" and "new" or "old") .. "_path"] end
						if ref == ref_name(point.ref) and relative == point.path then targeted = true end
					end
				end
				if targeted then matches[#matches + 1] = { buf = buf, point = point } end
			end
		end
	end
	return matches
end
local function saved_view(view, report)
	for _, entry in ipairs(loaded_endpoints(view)) do
		if vim.bo[entry.buf].modified then
			if report then notify("save source edits before review actions: " .. entry.point.path, vim.log.levels.WARN) end
			return false
		end
	end
	return true
end

--- Observations are action-time read evidence; navigation never collects or persists them.
local function observed_view(view)
	local observed = vim.deepcopy(view)
	observed.observations = {}
	for _, entry in ipairs(loaded_endpoints(view)) do
		local buf, point = entry.buf, entry.point
		observed.observations[#observed.observations + 1] = {
			ref = ref_name(point.ref), path = point.path, lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
			layout = point.layout or "file", fileformat = vim.bo[buf].fileformat, endofline = vim.bo[buf].endofline,
			encoding = vim.bo[buf].fileencoding ~= "" and vim.bo[buf].fileencoding or vim.o.encoding, bomb = vim.bo[buf].bomb,
		}
	end
	return observed
end

---@param all? boolean
---@param report? boolean Report unsupported/ambiguous action errors.
---@return table|nil
function M.view(all, report)
	for _, name in ipairs({ "codediff", "fugitive" }) do
		local viewer = adapter(name)
		if viewer then
			local view, err, active = viewer.resolve(all)
			if active then
				local tab = vim.api.nvim_get_current_tabpage()
				if not contexts[tab] and origins[tab] then contexts[tab] = { session = origins[tab].session }; origins[tab] = nil end
				if err and report then notify(err, vim.log.levels.WARN) end
				if report and not saved_view(view, true) then return end
				return view
			end
		end
	end
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)
	if vim.bo[buf].buftype ~= "" or name == "" then return end
	if vim.bo[buf].modified then if report then notify("save source edits before review actions", vim.log.levels.WARN) end; return end
	local repo = vim.fs.root(name, { ".git" })
	if not repo then return end
	local relative = name:sub(#repo + 2)
	return { repo = repo, viewer = "ordinary", line = vim.api.nvim_win_get_cursor(0)[1], files = {
		{ old = "INDEX:0", new = "WORKTREE", old_path = relative, new_path = relative, selected_side = "new", key = "ordinary:" .. relative } } }
end
local function signature(view)
	if not view then return "" end
	local copy = vim.deepcopy(view)
	copy.line = nil
	for _, file in ipairs(copy.files or {}) do file.line, file.selected_side, file.selected_ref, file.selected_path = nil, nil, nil, nil end
	return vim.json.encode(copy)
end

--- Synchronously repaint only the active session; no CLI work in decoration callbacks.
function M.redraw()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do if vim.api.nvim_buf_is_loaded(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end end
	for _, name in ipairs({ "codediff", "fugitive" }) do local loaded = package.loaded["review_session." .. name]; if loaded then loaded.clear() end end
	local ctx = M.context()
	if not ctx or not ctx.cache then return end
	local current = M.view(true)
	if signature(current) ~= ctx.cache.signature then return end
	local cache = ctx.cache
	if current.viewer == "ordinary" then
		local buf = vim.api.nvim_get_current_buf()
		for _, thread in ipairs(cache.threads) do
			for _, file in ipairs(cache.status.files) do
				if thread.anchor.fingerprint == file.fingerprint and thread.anchor.side == "new" then
					vim.api.nvim_buf_set_extmark(buf, ns, math.min((thread.anchor.start or 1) - 1, vim.api.nvim_buf_line_count(buf) - 1), 0,
						{ virt_text = { { "● " .. thread.id:sub(1, 8), "DiagnosticInfo" } } })
				end
			end
		end
	else
		local viewer = adapter(current.viewer)
		if viewer then viewer.decorate(cache) end
	end
end

---@param ctx? ReviewSessionContext
function M.refresh(ctx)
	local view = M.view(true)
	ctx = ctx or M.context()
	if not ctx then M.redraw(); return end
	if ctx ~= M.context() then return end
	if ctx.busy then ctx.again = true; return end
	if not view then ctx.cache = nil; M.redraw(); return end
	ctx.busy = true
	local stamp = signature(view)
	M.request(ctx, "view", { view = view }, function(status)
		M.request(ctx, "threads", { view = view }, function(threads)
			ctx.cache, ctx.busy = { descriptor = view, signature = stamp, status = status, threads = threads }, false
			if M.context() == ctx then M.redraw() end
			if ctx.again then ctx.again = false; M.refresh(ctx) end
		end, function() ctx.busy = false end)
	end, function() ctx.busy = false end)
end

---@param session string
---@param tab? integer
function M.attach(session, tab)
	tab = tab or vim.api.nvim_get_current_tabpage()
	contexts[tab] = { session = vim.fn.fnamemodify(session, ":p"):gsub("/$", "") }
	if tab == vim.api.nvim_get_current_tabpage() then M.redraw(); M.refresh() end
end
local function context()
	M.view(false)
	local ctx = M.context()
	if not ctx then notify("select a workspace with :ReviewSession folder", vim.log.levels.WARN) end
	return ctx
end
local function scratch(title, lines, editable)
	vim.cmd("botright new")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(buf, "review-session://" .. title .. "/" .. buf)
	vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile = editable and "acwrite" or "nofile", "hide", false
	vim.bo[buf].filetype = "markdown"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modified, vim.bo[buf].modifiable = false, editable or false
	return buf
end
local function compose(ctx, title, initial, operation, args, after)
	local buf = scratch(title, vim.split(initial or "", "\n", { plain = true }), true)
	local saving = false
	vim.api.nvim_create_autocmd("BufWriteCmd", { buffer = buf, callback = function()
		if saving then return end
		if operation == "create" and args.scope ~= "review" and not saved_view(args.view, true) then return end
		saving = true
		args.body = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		local sent = args.body
		M.request(ctx, operation, args, function(result)
			saving = false
			if vim.api.nvim_buf_is_valid(buf) then
				if table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") == sent then vim.bo[buf].modified = false end
				local message
				if operation == "edit" then for _, candidate in ipairs(result.messages) do if candidate.id == args.message then message = candidate end end
				else message = result.messages[#result.messages]; operation = "edit"; args = { thread = result.id, message = message.id } end
				args.revision = message.revision
			end
			if after then local callback = after; after = nil; callback(result) end
		end, function() saving = false end)
	end })
	return buf
end

--- Capture the action's current file pair in a single read-only query before composing.
local function selected(callback)
	local view = M.view(false, true)
	local ctx = context()
	if not ctx or not view then return end
	view = observed_view(view)
	M.request(ctx, "view", { view = view }, function(status)
		if not saved_view(view, true) then return end
		if #status.files ~= 1 then notify("select exactly one file pair", vim.log.levels.WARN); return end
		status.files[1].view.observations = view.observations
		callback(ctx, view, status.files[1])
	end)
end
function M.create(scope, first, last)
	if scope == "review" then
		local ctx = context(); if not ctx then return end
		local view = M.view(false) or vim.empty_dict()
		compose(ctx, "new-thread", "", "create", { view = view, scope = scope }, function(t) M.open_thread(t.id, ctx, false) end)
		return
	end
	selected(function(ctx, view, file)
		if scope == "range" and not view.line then notify("line/range comments require an open two-sided diff or source buffer", vim.log.levels.WARN); return end
		local args = { view = file.view, expected_fingerprint = file.fingerprint, scope = scope, side = file.selected_side or "new" }
		if scope == "range" then args.start, args["end"] = first or view.line, last or first or view.line end
		compose(ctx, "new-thread", "", "create", args, function(t) M.open_thread(t.id, ctx, false) end)
	end)
end
function M.toggle(all)
	local view = M.view(all, true)
	local ctx = context(); if not ctx or not view then return end
	view = observed_view(view)
	M.request(ctx, "view", { view = view }, function(status)
		if not saved_view(view, true) then return end
		local fingerprints = {}
		for _, file in ipairs(status.files) do fingerprints[#fingerprints + 1] = file.fingerprint end
		M.request(ctx, "mark", { view = view, expected_fingerprints = fingerprints }, function() M.refresh(ctx) end)
	end)
end
function M.reanchor(id, scope, first, last)
	selected(function(ctx, view, file)
		if scope == "range" and not view.line then notify("line anchors require an open diff"); return end
		M.request(ctx, "reanchor", { thread = id, view = file.view, expected_fingerprint = file.fingerprint,
			scope = scope, side = file.selected_side or "new", start = first or view.line, ["end"] = last or first or view.line }, function() notify("publication location selected; original source retained") end)
	end)
end

---@param target table Thread ID or reviewed fingerprint request fields.
---@param side? string
---@param ctx? ReviewSessionContext
function M.open_source(target, side, ctx)
	ctx = ctx or context(); if not ctx then return end
	if type(target) == "string" then target = { thread = target } end
	M.request(ctx, "source", vim.tbl_extend("force", target, { side = side }), function(result)
		local buf = scratch("source/" .. result.side .. "/" .. result.path, vim.split(result.text, "\n", { plain = true }), false)
		vim.bo[buf].filetype = vim.filetype.match({ filename = result.path }) or "text"
		vim.api.nvim_win_set_cursor(0, { math.min(result.start, vim.api.nvim_buf_line_count(buf)), 0 })
	end)
end
local function reopen(ctx, target, done)
	local settled = false
	local function complete()
		if settled then return end
		settled = true
		done()
	end
	local function fallback()
		if settled then return end
		settled = true
		M.request(ctx, "source", target, function(source)
			local buf = scratch("original/" .. source.path, vim.split(source.text, "\n", { plain = true }), false)
			vim.bo[buf].filetype = vim.filetype.match({ filename = source.path }) or "text"
			vim.api.nvim_win_set_cursor(0, { math.min(source.start, vim.api.nvim_buf_line_count(buf)), 0 })
			done()
		end, done)
	end
	M.request(ctx, "context", target, function(result)
		local anchor = result.anchor
		local viewer = options.viewer or "codediff"
		local open = type(viewer) == "function" and viewer or (adapter(viewer) or {}).open
		local function ready()
			M.request(ctx, "context", vim.tbl_extend("force", target, { observations = observed_view(result.view).observations }), function(latest)
				if latest.available and saved_view(latest.view, false) then complete() else fallback() end
			end, fallback)
		end
		if result.available and saved_view(result.view, false) and open and open(anchor, ready, fallback) then return end
		fallback()
	end, complete)
end

---@param id string
---@param ctx? ReviewSessionContext
---@param original? boolean Open original context when it differs from the current view.
function M.open_thread(id, ctx, original)
	ctx = ctx or context(); if not ctx then return end
	M.request(ctx, "show", { thread = id }, function(result)
		local thread = result.thread
		local function display()
			local buf = scratch(id, vim.split(result.markdown, "\n", { plain = true }), false)
			vim.b[buf].review_thread = id
			local function map(key, fn, description) vim.keymap.set("n", key, fn, { buffer = buf, desc = description }) end
			local function reload() M.open_thread(id, ctx, false) end
			local function select_message(callback)
				vim.ui.select(thread.messages, { prompt = "Message", format_item = function(m) return m.role .. ": " .. m.body:gsub("\n", " "):sub(1, 100) end }, callback)
			end
			map("R", reload, "Reload external replies")
			map("r", function() compose(ctx, "reply", "", "reply", { thread = id }, reload) end, "Reply (save Markdown)")
			map("e", function() select_message(function(m) if m then compose(ctx, "edit", m.body, "edit", { thread = id, message = m.id, revision = m.revision }) end end) end, "Edit message")
			map("s", function() M.request(ctx, "share", { thread = id, value = thread.shared and "human-only" or "shared" }, reload) end, "Toggle sharing")
			map("x", function() M.request(ctx, "resolve", { thread = id, value = thread.resolved and "open" or "resolved" }, reload) end, "Toggle resolved")
			map("d", function() select_message(function(m) if m then M.request(ctx, "draft", { thread = id, message = m.id, revision = m.revision }, function() notify("publication draft selected") end) end end) end, "Select publication draft")
			map("o", function() M.open_source({ thread = id }, nil, ctx) end, "Original source snapshot")
			map("O", function() M.open_source({ thread = id }, thread.anchor.side == "old" and "new" or "old", ctx) end, "Opposite source snapshot")
			local function publish(summary)
				vim.ui.input({ prompt = "Destination owner/repo#number: " }, function(destination)
					if not destination then return end
					M.request(ctx, "preview", { thread = id, destination = destination, summary = summary }, function(preview)
						scratch("publication-preview", { "# " .. destination, "", vim.inspect(preview.payload) }, false)
						vim.ui.select({ "Cancel", "Publish selected draft" }, { prompt = "Publish this preview?" }, function(choice)
							if choice == "Publish selected draft" then M.request(ctx, "publish", { thread = id, destination = destination, summary = summary, revision = preview.draft.revision, expected_preview = preview.token }, function(receipt) notify(vim.inspect(receipt.receipt)) end) end
						end)
					end)
				end)
			end
			map("p", function() publish(false) end, "Preview inline publication")
			map("P", function() publish(true) end, "Preview explicit PR-wide summary")
		end
		local same = false
		for _, file in ipairs(ctx.cache and ctx.cache.status.files or {}) do if file.fingerprint == thread.anchor.fingerprint then same = true end end
		if original ~= false and not same and thread.anchor.scope ~= "review" then reopen(ctx, { thread = id }, display) else display() end
	end)
end

---@param wide? boolean Session-wide instead of current-view threads.
function M.pick(wide)
	local ctx = context(); if not ctx then return end
	local args = {}
	if not wide then
		local view = M.view(true)
		if view then args.view = view end
	end
	M.request(ctx, "threads", args, function(threads)
		local entries, ids = {}, {}
		for _, t in ipairs(threads) do
			local line = t.id .. " " .. (t.shared and "shared" or "human-only") .. (t.other_revision and " other revision" or "") .. (t.outdated and " outdated" or "") .. " " .. (t.anchor.path or "review") .. " " .. t.messages[1].body:gsub("[\r\n]", " ")
			entries[#entries + 1], ids[line] = line, t.id
		end
		local ok, fzf = pcall(require, "fzf-lua")
		if ok then fzf.fzf_exec(entries, { prompt = wide and "Session threads> " or "View threads> ", actions = { default = function(selected) if selected[1] then M.open_thread(ids[selected[1]], ctx) end end } })
		else vim.ui.select(entries, { prompt = "Review threads" }, function(choice) if choice then M.open_thread(ids[choice], ctx) end end) end
	end)
end
function M.history(wide)
	local ctx = context(); if not ctx then return end
	local view = not wide and M.view(true) or nil
	M.request(ctx, "history", { view = view }, function(pairs)
		vim.ui.select(pairs, { prompt = "Reviewed file pairs", format_item = function(pair)
			return pair.path .. " " .. pair.old_ref .. " → " .. pair.new_ref .. " [" .. pair.fingerprint:sub(1, 12) .. "]"
		end }, function(pair) if pair then reopen(ctx, { fingerprint = pair.fingerprint }, function() end) end end)
	end)
end

---@param opts? ReviewSessionOptions
function M.setup(opts)
	options = opts or {}
	local group = vim.api.nvim_create_augroup("review_session", { clear = true })
	vim.api.nvim_create_autocmd("TabLeave", { group = group, callback = function() leaving = M.context() end })
	vim.api.nvim_create_autocmd("TabNewEntered", { group = group, callback = function() origins[vim.api.nvim_get_current_tabpage()] = leaving end })
	vim.api.nvim_create_autocmd({ "TabEnter", "BufEnter", "WinEnter" }, { group = group, callback = function()
		M.redraw(); vim.schedule(function() M.refresh() end)
	end })
	vim.api.nvim_create_autocmd("CursorMoved", { group = group, callback = function()
		if type(vim.b.fugitive_status) == "table" then
			local ctx, view = M.context(), M.view(true)
			if ctx and view and (not ctx.cache or ctx.cache.signature ~= signature(view)) then M.refresh() else M.redraw() end
		end
	end })
	vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, { group = group, callback = function() M.refresh() end })
	vim.api.nvim_create_autocmd("TabClosed", { group = group, callback = function()
		for tab in pairs(contexts) do if not vim.api.nvim_tabpage_is_valid(tab) then contexts[tab], origins[tab] = nil, nil end end
	end })
	for _, name in ipairs({ "codediff", "fugitive" }) do local viewer = adapter(name); if viewer and viewer.setup then viewer.setup(group, function() M.refresh() end, M.redraw) end end
	local function command(name, fn, spec) vim.api.nvim_create_user_command(name, fn, vim.tbl_extend("force", spec or {}, { force = true })) end
	command("ReviewSession", function(cmd) M.attach(cmd.args) end, { nargs = 1, complete = "dir" })
	command("ReviewInit", function(cmd)
		local ctx = { session = cmd.fargs[1] }
		local tab = vim.api.nvim_get_current_tabpage()
		M.request(ctx, "init", { repo = cmd.fargs[2] or vim.fn.getcwd() }, function() M.attach(ctx.session, tab); notify("review workspace created") end)
	end, { nargs = "+", complete = "dir" })
	command("ReviewThreads", function(cmd) M.pick(cmd.bang) end, { bang = true })
	command("ReviewReviewed", function(cmd) M.history(cmd.bang) end, { bang = true })
	command("ReviewThread", function(cmd) M.open_thread(cmd.args) end, { nargs = 1 })
	command("ReviewNote", function() M.create("review") end)
	command("ReviewFile", function() M.create("file") end)
	command("ReviewComment", function(cmd) M.create("range", cmd.range > 0 and cmd.line1 or nil, cmd.range > 0 and cmd.line2 or nil) end, { range = true })
	command("ReviewReanchor", function(cmd) M.reanchor(cmd.args, cmd.range > 0 and "range" or "file", cmd.range > 0 and cmd.line1 or nil, cmd.range > 0 and cmd.line2 or nil) end, { nargs = 1, range = true })
	command("ReviewToggle", function() M.toggle(false) end)
	command("ReviewToggleAll", function() M.toggle(true) end)
	command("ReviewProgress", function()
		local ctx = context(); local view = M.view(true, true); if not ctx or not view then return end
		M.request(ctx, "view", { view = view }, function(status)
			local lines = { string.format("Reviewed %d / %d current file pairs", status.reviewed, status.total) }
			for _, file in ipairs(status.files) do lines[#lines + 1] = file.reviewed .. " " .. file.path end
			notify(table.concat(lines, "\n"))
		end)
	end)
	if options.keys ~= false then
		vim.keymap.set("n", "<leader>rv", function() M.toggle(false) end, { desc = "Toggle current file pair reviewed" })
		vim.keymap.set("n", "<leader>rV", function() M.toggle(true) end, { desc = "Toggle current view reviewed" })
	end
end
return M

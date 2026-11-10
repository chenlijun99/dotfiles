--- Optional codediff adapter. Its internals never escape this module.
local M = {}
local ns = vim.api.nvim_create_namespace("review_session_codediff")
local function lifecycle()
	local ok, value = pcall(require, "codediff.ui.lifecycle")
	return ok and value or nil
end
local function path(ref) return ref and ref.relative ~= "" and ref.relative or nil end
local function item(comp, key, side, data)
	if not comp then return end
	data = data or {}
	return { old = comp.original_revision or (path(comp.original) and "WORKTREE") or data.base_revision or "HEAD",
		new = comp.modified_revision or (path(comp.modified) and "WORKTREE") or data.target_revision or "WORKTREE",
		old_path = path(comp.original), new_path = path(comp.modified), key = key, selected_side = path(comp.modified) and side or "old" }
end
local function panel_row(panel, row, displayed)
	local data = vim.tbl_extend("force", {}, panel.view.data)
	-- Symbolic source_revisions are refresh dependencies, not displayed endpoint identities.
	data.source_revisions = nil
	local fixed = require("codediff.core.git.revision").is_fixed
	local function mutable(ref) return ref == nil or ref == "WORKING" or ref:match("^:[0-3]:?$") end
	local err = "viewer revisions are changing or unresolved; refresh the viewer and reselect the source"
	if panel.name == "explorer" and data.base_revision then
		if not mutable(data.base_revision) and not fixed(data.base_revision) then
			if not displayed.original_revision or not fixed(displayed.original_revision) then return nil, err end
			data.base_revision = displayed.original_revision
		end
		if data.target_revision and not mutable(data.target_revision) and not fixed(data.target_revision) then
			if not displayed.modified_revision or not fixed(displayed.modified_revision) then return nil, err end
			data.target_revision = displayed.modified_revision
		end
		if (displayed.original_revision and displayed.original_revision ~= data.base_revision)
			or (displayed.modified_revision and displayed.modified_revision ~= data.target_revision) then return nil, err end
	elseif panel.name == "history" and data.opts.base_revision then
		local base = data.opts.base_revision
		if not mutable(base) and not fixed(base) then
			if not displayed.original_revision or not fixed(displayed.original_revision) then return nil, err end
			base = displayed.original_revision
		end
		data.opts = vim.tbl_extend("force", {}, data.opts, { base_revision = base })
		data.base_revision = base
	end
	local comparison = require("codediff.ui.refresh.panel").comparison({ name = panel.name, data = data }, row)
	if panel.name == "history" then
		data.target_revision = row.commit_hash
		if not data.base_revision then
			local parents = (data.parents or {})[row.commit_hash]
			data.base_revision = parents and (parents[1] or row.commit_hash) or row.commit_hash .. "^"
		end
	end
	return comparison, nil, data
end

---@param all? boolean Include every change row, including collapsed directories.
---@return table|nil, string|nil, boolean Descriptor, action error, viewer active.
function M.resolve(all)
	local lc = lifecycle()
	if not lc then return nil, nil, false end
	local tab, buf = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_buf()
	local session = lc.get_session(tab)
	if not session then return nil, nil, false end
	local old, new = lc.get_buffers(tab)
	local panel = lc.get_panel(tab)
	local in_panel = panel and panel.view and panel.view.bufnr == buf
	if not all and buf ~= old and buf ~= new and not in_panel then return nil, nil, false end
	if session.conflict or session.result_bufnr then return nil, "three-way/conflict diffs are unsupported; open a two-sided comparison", true end
	local git = lc.get_git_context(tab)
	if not git or not git.git_root then return nil, "review actions require a Git comparison", true end
	local files = {}
	if all and panel and panel.view then
		local data = panel.view.data
		if panel.name == "explorer" then
			for _, group in ipairs({ "staged", "unstaged", "conflicts" }) do
				for _, entry in ipairs((data.status_result or {})[group] or {}) do
					if group == "conflicts" then return nil, "three-way/conflict diffs are unsupported", true end
					local row = vim.tbl_extend("force", entry, { group = group })
					local comparison, err, resolved = panel_row(panel, row, git)
					if not comparison then return nil, err, true end
					table.insert(files, item(comparison, group .. ":" .. entry.path, nil, resolved))
				end
			end
		elseif panel.name == "history" then
			local commit = data.current_commit
			for _, entry in ipairs((data.files or {})[commit] or {}) do
				local row = vim.tbl_extend("force", entry, { commit_hash = commit })
				local comparison, err, resolved = panel_row(panel, row, git)
				if not comparison then return nil, err, true end
				table.insert(files, item(comparison, commit .. ":" .. entry.path, nil, resolved))
			end
		end
	elseif in_panel then
		local node = panel.view.tree:get_node(vim.api.nvim_win_get_cursor(0)[1])
		local row = node and node.data
		if not row or not row.path or (row.type and row.type ~= "file") then return nil, "select a file row", true end
		local comparison, err, resolved = panel_row(panel, row, git)
		if not comparison then return nil, err, true end
		table.insert(files, item(comparison, (row.group or row.commit_hash or "") .. ":" .. row.path, "new", resolved))
	else
		if vim.bo[buf].modified then return nil, "save source edits before review actions", true end
		local original, modified = lc.get_paths(tab)
		local data = panel and panel.view and panel.view.data or {}
		if panel and data.current_selection then
			local comparison, err, resolved = panel_row(panel, data.current_selection, git)
			if not comparison then return nil, err, true end
			data = resolved
		end
		local key = (data.current_file_group or data.current_commit or "") .. ":" .. (path(modified) or path(original) or "")
		table.insert(files, item({ original = original, modified = modified, original_revision = git.original_revision,
			modified_revision = git.modified_revision }, key, buf == old and "old" or "new", data))
	end
	if #files == 0 and all then
		local original, modified = lc.get_paths(tab)
		if not path(original) and not path(modified) then return nil, "select a file in the viewer", true end
		table.insert(files, item({ original = original, modified = modified, original_revision = git.original_revision,
			modified_revision = git.modified_revision }, "current", "new"))
	end
	return { repo = git.git_root, files = files, viewer = "codediff", line = not in_panel and vim.api.nvim_win_get_cursor(0)[1] or nil }, nil, true
end

function M.clear()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
	end
end

---@param cache table|nil
function M.decorate(cache)
	local ctx = require("review_session").context()
	if cache and (not ctx or ctx.cache ~= cache) then return end
	M.clear()
	local lc = lifecycle()
	if not lc or not cache then return end
	local tab = vim.api.nvim_get_current_tabpage()
	local old, new = lc.get_buffers(tab)
	local panel = lc.get_panel(tab)
	local statuses = {}
	for _, file in ipairs(cache.status.files) do statuses[file.key or ""] = file end
	if panel and panel.view and panel.view.tree and vim.api.nvim_buf_is_valid(panel.view.bufnr) then
		for line = 1, vim.api.nvim_buf_line_count(panel.view.bufnr) do
			local node = panel.view.tree:get_node(line)
			local row = node and node.data
			local key = row and (row.group or row.commit_hash or "") .. ":" .. (row.path or "")
			local file = key and statuses[key]
			if file then vim.api.nvim_buf_set_extmark(panel.view.bufnr, ns, line - 1, 0, { virt_text = { {
				file.reviewed == "reviewed" and "✓" or file.reviewed == "another" and "◐" or "○", file.reviewed == "reviewed" and "DiagnosticOk" or "Comment" } }, virt_text_pos = "right_align" }) end
		end
	end
	local original, modified = lc.get_paths(tab)
	for _, entry in ipairs({ { old, "old", path(original) }, { new, "new", path(modified) } }) do
		local buf, side, relative = unpack(entry)
		if buf and vim.api.nvim_buf_is_valid(buf) then
			for _, thread in ipairs(cache.threads) do
				local a = thread.anchor
				for _, file in ipairs(cache.status.files) do
					if a.fingerprint == file.fingerprint and a.side == side and a[side .. "_path"] == relative then
						vim.api.nvim_buf_set_extmark(buf, ns, math.min((a.start or 1) - 1, vim.api.nvim_buf_line_count(buf) - 1), 0,
							{ virt_text = { { "● " .. thread.id:sub(1, 8), "DiagnosticInfo" } } })
					end
				end
			end
		end
	end
end

---@param bufnr integer
---@return table|nil
function M.endpoint(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if not name:match("^codediff:///") then return end
	local repo, ref, relative = require("codediff.core.virtual_file").parse_url(name)
	if repo then return { repo = repo, ref = ref, path = relative, layout = "lines" } end
end

---@param anchor table
---@param done fun()
---@param failed? fun() Async command failure falls back to retained snapshots.
---@return boolean Whether opening was dispatched.
function M.open(anchor, done, failed)
	local old, new = anchor.old_ref, anchor.new_ref
	local args = { "--repo", anchor.repo }
	if old:match("^INDEX:") or old == "WORKTREE" or (new:match("^INDEX:") and new ~= "INDEX:0") then return false end
	if new == "INDEX:0" then vim.list_extend(args, { "--staged", old })
	elseif new == "WORKTREE" then table.insert(args, old)
	else vim.list_extend(args, { old, new }) end
	vim.list_extend(args, { "--", anchor.new_path or anchor.old_path })
	if anchor.old_path and anchor.new_path and anchor.old_path ~= anchor.new_path then table.insert(args, anchor.old_path) end
	local opened, finished, hooks = nil, false, {}
	local timer
	local function complete(success)
		if finished then return end
		finished = true
		for _, hook in ipairs(hooks) do pcall(vim.api.nvim_del_autocmd, hook) end
		if timer and not timer:is_closing() then timer:stop(); timer:close() end
		if success then done() elseif failed then failed() end
	end
	hooks[#hooks + 1] = vim.api.nvim_create_autocmd("User", { pattern = "CodeDiffOpen", callback = function(event)
		local tab = event.data and event.data.tabpage or vim.api.nvim_get_current_tabpage()
		local lc = lifecycle()
		local git = lc and lc.get_git_context(tab)
		if git and git.git_root == anchor.repo then opened = tab end
	end })
	hooks[#hooks + 1] = vim.api.nvim_create_autocmd("User", { pattern = "CodeDiffFileSelect", callback = function(event)
		local tab = event.data and event.data.tabpage or vim.api.nvim_get_current_tabpage()
		if opened and tab == opened then vim.schedule(function() complete(true) end) end
	end })
	timer = vim.defer_fn(function() complete(false) end, 5000)
	local ok = pcall(vim.api.nvim_cmd, { cmd = "CodeDiff", args = args }, {})
	if not ok then
		finished = true
		for _, hook in ipairs(hooks) do pcall(vim.api.nvim_del_autocmd, hook) end
		if not timer:is_closing() then timer:stop(); timer:close() end
	end
	return ok
end

function M.setup(group, refresh, redraw)
	vim.api.nvim_create_autocmd("User", { group = group, pattern = { "CodeDiffOpen", "CodeDiffFileSelect" }, callback = function()
		local lc = lifecycle()
		local panel = lc and lc.get_panel(vim.api.nvim_get_current_tabpage())
		local view = panel and panel.view
		if view and view.tree and not view._review_session_render then
			view._review_session_render = true
			local render = view.tree.render
			view.tree.render = function(self, ...)
				local result = render(self, ...)
				vim.schedule(redraw)
				return result
			end
		end
		refresh()
	end })
end

return M

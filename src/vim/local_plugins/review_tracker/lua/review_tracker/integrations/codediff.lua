---@class ReviewTrackerIntegration
local M = {}

local core = require("review_tracker.core")
local ns = vim.api.nvim_create_namespace("review_tracker_codediff")

local function setup_highlights()
	vim.api.nvim_set_hl(0, "ReviewTrackerReviewed", { default = true, link = "DiffAdd" })
end

local function get_lifecycle()
	local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
	return ok and lifecycle or nil
end

local function get_explorer(lifecycle, tabpage)
	if lifecycle.get_panel_name(tabpage) ~= "explorer" then
		return nil
	end
	return lifecycle.get_panel_view(tabpage)
end

local function changed_files(status)
	local seen = {}
	local paths = {}
	local groups = { status.unstaged or {}, status.staged or {}, status.conflicts or {} }
	for _, group in ipairs(groups) do
		for _, file in ipairs(group) do
			local path = file.path
			if path and path ~= "" and not seen[path] then
				seen[path] = true
				table.insert(paths, path)
			end
		end
	end
	return paths
end

local function is_text_file(path)
	local fd = vim.uv.fs_open(path, "r", 0)
	if not fd then
		return false
	end
	local sample = vim.uv.fs_read(fd, 8000, 0)
	vim.uv.fs_close(fd)
	return sample ~= nil and not sample:find("\0", 1, true)
end

-- Wrap explorer.tree.render so every render — file selection, auto-refresh, manual R,
-- window resize — triggers re-decoration. We mark the explorer with a flag to avoid
-- double-wrapping if CodeDiffFileSelect fires more than once for the same session.
local function ensure_render_hooked(explorer, tabpage)
	if explorer._review_tracker_hooked then
		return
	end
	explorer._review_tracker_hooked = true

	local original_render = explorer.tree.render
	explorer.tree.render = function(self)
		original_render(self)
		-- Schedule after the render so codediff's own highlight extmarks are applied first.
		vim.schedule(function()
			M.decorate_explorer(tabpage)
		end)
	end
end

function M.decorate_explorer(tabpage)
	tabpage = tabpage or vim.api.nvim_get_current_tabpage()
	local lifecycle = get_lifecycle()
	if not lifecycle then
		return
	end

	local explorer = get_explorer(lifecycle, tabpage)
	if not explorer or not vim.api.nvim_buf_is_valid(explorer.bufnr) then
		return
	end

	local git_root = explorer.data.git_root
	if not git_root then
		return
	end

	vim.api.nvim_buf_clear_namespace(explorer.bufnr, ns, 0, -1)

	local line_count = vim.api.nvim_buf_line_count(explorer.bufnr)
	for line = 1, line_count do
		local node = explorer.tree:get_node(line)
		if node and node.data and node.data.path and node.data.type == nil then
			local abs_path = git_root .. "/" .. node.data.path
			if core.is_reviewed(abs_path) then
				vim.api.nvim_buf_set_extmark(explorer.bufnr, ns, line - 1, 0, {
					line_hl_group = "ReviewTrackerReviewed",
					virt_text = { { "✓", "DiagnosticOk" } },
					virt_text_pos = "right_align",
					priority = 200,
				})
			else
				vim.api.nvim_buf_set_extmark(explorer.bufnr, ns, line - 1, 0, {
					virt_text = { { "○", "Comment" } },
					virt_text_pos = "right_align",
					priority = 200,
				})
			end
		end
	end
end

function M.show_progress()
	local lifecycle = get_lifecycle()
	if not lifecycle then
		vim.notify("review_tracker: codediff.nvim not available", vim.log.levels.WARN)
		return
	end

	local tabpage = vim.api.nvim_get_current_tabpage()
	local explorer = get_explorer(lifecycle, tabpage)
	if not explorer then
		vim.notify("review_tracker: no active CodeDiff session", vim.log.levels.WARN)
		return
	end

	local git_root = explorer.data.git_root
	local status = explorer.data.status_result
	if not git_root or not status then
		return
	end

	local all_files = changed_files(status)

	local reviewed_list = {}
	local unreviewed_list = {}
	for _, rel_path in ipairs(all_files) do
		local abs_path = git_root .. "/" .. rel_path
		if core.is_reviewed(abs_path) then
			table.insert(reviewed_list, "✓ " .. rel_path)
		else
			table.insert(unreviewed_list, "○ " .. rel_path)
		end
	end

	local total = #all_files
	local done = #reviewed_list
	local lines = { string.format("Review progress: %d / %d", done, total) }
	if #reviewed_list > 0 then
		table.insert(lines, "")
		table.insert(lines, "Reviewed:")
		for _, s in ipairs(reviewed_list) do
			table.insert(lines, "  " .. s)
		end
	end
	if #unreviewed_list > 0 then
		table.insert(lines, "")
		table.insert(lines, "Pending:")
		for _, s in ipairs(unreviewed_list) do
			table.insert(lines, "  " .. s)
		end
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Review Progress" })
end

function M.toggle_all_reviewed()
	local lifecycle = get_lifecycle()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local explorer = lifecycle and get_explorer(lifecycle, tabpage)
	if not explorer then
		vim.notify("review_tracker: no active CodeDiff explorer", vim.log.levels.WARN)
		return
	end

	local git_root = explorer.data.git_root
	local status = explorer.data.status_result
	if not git_root or not status then
		vim.notify("review_tracker: no Git file list to mark", vim.log.levels.WARN)
		return
	end

	local files = {}
	local all_reviewed = true
	local binary_paths = {}
	for _, group in ipairs({ status.unstaged or {}, status.staged or {}, status.conflicts or {} }) do
		for _, file in ipairs(group) do
			if file.line_stats and file.line_stats.binary then
				binary_paths[file.path] = true
			end
		end
	end
	for _, rel_path in ipairs(changed_files(status)) do
		local abs_path = git_root .. "/" .. rel_path
		local stat = vim.uv.fs_lstat(abs_path)
		if not binary_paths[rel_path] and stat and stat.type == "file" and is_text_file(abs_path) then
			local reviewed = core.is_reviewed(abs_path)
			table.insert(files, { path = abs_path, reviewed = reviewed })
			if not reviewed then
				all_reviewed = false
			end
		end
	end

	if #files == 0 then
		vim.notify("review_tracker: no working-tree files to mark", vim.log.levels.WARN)
		return
	end

	local mark_reviewed = not all_reviewed
	for _, file in ipairs(files) do
		if file.reviewed ~= mark_reviewed then
			core.set_reviewed(file.path, mark_reviewed)
		end
	end
	M.on_toggle()
end

-- Resolve the real working-tree file from the current buffer, when that buffer
-- is part of a codediff session (explorer sidebar or either diff pane).
-- Returns an absolute path string, or nil when the context is not codediff.
function M.resolve_file(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lifecycle = get_lifecycle()
	if not lifecycle then return nil end

	local tabpage = vim.api.nvim_get_current_tabpage()

	-- Explorer buffer: resolve from the file node under the cursor.
	if vim.bo[bufnr].filetype == "codediff-explorer" then
		local explorer = get_explorer(lifecycle, tabpage)
		if not explorer or not explorer.data.git_root then return nil end
		local win = vim.fn.bufwinid(bufnr)
		if win == -1 then return nil end
		local line = vim.api.nvim_win_get_cursor(win)[1]
		local node = explorer.tree:get_node(line)
		if node and node.data and node.data.path and node.data.type == nil then
			return explorer.data.git_root .. "/" .. node.data.path
		end
		return nil  -- cursor on group/directory header, not a file
	end

	-- Either diff pane: use the explorer's tracked current file.
	-- This covers both the real working-tree buffer and the virtual codediff:// buffer.
	local ob, mb = lifecycle.get_buffers(tabpage)
	if bufnr == ob or bufnr == mb then
		local explorer = get_explorer(lifecycle, tabpage)
		if explorer and explorer.data.git_root and explorer.data.current_file_path and explorer.data.current_file_path ~= "" then
			return explorer.data.git_root .. "/" .. explorer.data.current_file_path
		end
	end

	return nil
end

function M.on_toggle(_filepath)
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local lifecycle = get_lifecycle()
		if lifecycle and get_explorer(lifecycle, tabpage) then
			M.decorate_explorer(tabpage)
		end
	end
end

function M.setup()
	setup_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = setup_highlights,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeDiffFileSelect",
		callback = function(event)
			local tabpage = (event.data and event.data.tabpage) or vim.api.nvim_get_current_tabpage()
			local lifecycle = get_lifecycle()
			if lifecycle then
				local explorer = get_explorer(lifecycle, tabpage)
				if explorer then
					ensure_render_hooked(explorer, tabpage)
				end
			end
			vim.schedule(function()
				M.decorate_explorer(tabpage)
			end)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function()
			local lifecycle = get_lifecycle()
			if not lifecycle then
				return
			end
			for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
				if get_explorer(lifecycle, tabpage) then
					vim.schedule(function()
						M.decorate_explorer(tabpage)
					end)
					break
				end
			end
		end,
	})

	vim.api.nvim_create_user_command("ReviewProgress", M.show_progress, {})
end

return M

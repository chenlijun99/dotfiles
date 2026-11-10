--- Optional Fugitive adapter; pairs come from actual diff partners, never window geometry.
local M = {}
local ns = vim.api.nvim_create_namespace("review_session_fugitive")
local function endpoint(buf)
	if vim.fn.exists("*FugitiveParse") == 0 then return end
	local name = vim.api.nvim_buf_get_name(buf)
	local parsed = vim.fn.FugitiveParse(name)
	if parsed and parsed[1] and parsed[1] ~= "" then
		local object = parsed[1]
		local ref, relative = object:match("^(:[0-3]):(.*)$")
		if not ref then ref, relative = object:match("^([^:]+):(.*)$") end
		if ref and relative then return { ref = ref, path = relative, buf = buf, repo = vim.fn.FugitiveWorkTree(buf) } end
	end
	if vim.bo[buf].buftype == "" and name ~= "" then
		local repo = vim.fn.FugitiveWorkTree(buf)
		if repo ~= "" and name:sub(1, #repo + 1) == repo .. "/" then return { ref = "WORKTREE", path = name:sub(#repo + 2), buf = buf, repo = repo } end
	end
end
M.endpoint = endpoint

local function status_rows(buf)
	local status = vim.b[buf].fugitive_status
	if type(status) ~= "table" then return end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local selected, section = vim.api.nvim_win_get_cursor(0)[1], nil
	for line = 1, selected do
		local heading = lines[line]:match("^(%u%l+).- %(%d+%+?%)$")
		if heading then section = heading end
	end
	if section ~= "Staged" and section ~= "Unstaged" then return nil, "select a staged or unstaged file section" end
	local records, rows = (status.files or {})[section] or {}, {}
	local active
	for line, text in ipairs(lines) do
		local heading = text:match("^(%u%l+).- %(%d+%+?%)$")
		if heading then active = heading end
		local display = text:match("^[A-Z?] (.*)$")
		local record = active == section and display and records[display]
		if record then
			local relative = record.relative or { display }
			local old_path, new_path = relative[#relative], relative[1]
			local code = text:sub(1, 1)
			if code == "A" or code == "?" then old_path = nil end
			if code == "D" then new_path = nil end
			rows[#rows + 1] = { old = section == "Staged" and "HEAD" or "INDEX:0", new = section == "Staged" and "INDEX:0" or "WORKTREE",
				old_path = old_path, new_path = new_path,
				key = section .. ":" .. display, line = line, selected_side = new_path and "new" or "old" }
		end
	end
	return rows, nil, selected
end

---@param all? boolean Bulk status is limited to the selected staged/unstaged section.
---@return table|nil, string|nil, boolean
function M.resolve(all)
	if vim.fn.exists("*FugitiveParse") == 0 then return nil, nil, false end
	local buf = vim.api.nvim_get_current_buf()
	if type(vim.b[buf].fugitive_status) == "table" then
		local rows, err, selected = status_rows(buf)
		if not rows then return nil, err, true end
		local files = rows
		if not all then
			files = {}
			for _, row in ipairs(rows) do if row.line == selected then files[1] = row end end
			if #files == 0 then return nil, "select a file row (line comments require an open diff)", true end
		end
		return { repo = vim.fn.FugitiveWorkTree(buf), files = files, viewer = "fugitive", status = true }, nil, true
	end
	local current = endpoint(buf)
	local partners = {}
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.wo[win].diff then
			local candidate = endpoint(vim.api.nvim_win_get_buf(win))
			if candidate then partners[#partners + 1] = candidate end
		end
	end
	local in_diff = vim.wo.diff
	if all and not in_diff and #partners > 0 then current = partners[1] end
	if not current then return nil, nil, false end
	if not in_diff and not (all and #partners > 0) then return nil, "open a two-sided Fugitive diff for a versioned review action", vim.bo[buf].filetype == "fugitive" end
	if #partners ~= 2 then return nil, "ambiguous or three-way diff; open exactly two source panes", true end
	local other = partners[1].buf == current.buf and partners[2] or partners[1]
	if other.buf == current.buf or current.repo ~= other.repo then return nil, "ambiguous diff partners", true end
	if vim.bo[current.buf].modified or vim.bo[other.buf].modified then return nil, "save source edits before review actions", true end
	return { repo = current.repo, viewer = "fugitive", line = in_diff and vim.api.nvim_win_get_cursor(0)[1] or nil, files = {
		{ old = current.ref, new = other.ref, old_path = current.path, new_path = other.path, orient = true,
			selected_ref = current.ref, selected_path = current.path, key = "diff" } } }, nil, true
end

function M.clear()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do if vim.api.nvim_buf_is_loaded(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end end
end
function M.decorate(cache)
	local ctx = require("review_session").context()
	if cache and (not ctx or ctx.cache ~= cache) then return end
	M.clear()
	if not cache then return end
	local view = M.resolve(true)
	if not view then return end
	local files = {}
	for _, file in ipairs(cache.status.files) do files[file.key or ""] = file end
	if view.status then
		local buf = vim.api.nvim_get_current_buf()
		for _, row in ipairs(view.files) do
			local file = files[row.key]
			if file then vim.api.nvim_buf_set_extmark(buf, ns, row.line - 1, 0, { virt_text = { {
				file.reviewed == "reviewed" and "✓" or file.reviewed == "another" and "◐" or "○", "Comment" } }, virt_text_pos = "right_align" }) end
		end
	else
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			local point = endpoint(vim.api.nvim_win_get_buf(win))
			if point and vim.wo[win].diff then
				for _, thread in ipairs(cache.threads) do
					local a = thread.anchor
					for _, file in ipairs(cache.status.files) do
						if a.fingerprint == file.fingerprint and a[a.side .. "_path"] == point.path and a[a.side .. "_ref"] == (point.ref:match("^:") and ("INDEX:" .. point.ref:sub(2)) or point.ref) then
							vim.api.nvim_buf_set_extmark(point.buf, ns, math.min((a.start or 1) - 1, vim.api.nvim_buf_line_count(point.buf) - 1), 0, { virt_text = { { "● " .. thread.id:sub(1, 8), "DiagnosticInfo" } } })
						end
					end
				end
			end
		end
	end
end

function M.open(anchor, done)
	if vim.fn.exists("*FugitiveFind") == 0 or not anchor.old_path or not anchor.new_path then return false end
	local function name(ref, relative)
		if ref == "WORKTREE" then return anchor.repo .. "/" .. relative end
		local object = (ref:match("^INDEX:") and (":" .. ref:sub(-1)) or ref) .. ":" .. relative
		return vim.fn.FugitiveFind(object, anchor.repo .. "/.git")
	end
	local ok = pcall(function()
		vim.cmd("tabnew")
		vim.api.nvim_cmd({ cmd = "edit", args = { name(anchor.new_ref, anchor.new_path) } }, {})
		vim.api.nvim_cmd({ cmd = "Gdiffsplit", args = { name(anchor.old_ref, anchor.old_path) } }, {})
		done()
	end)
	return ok
end
return M

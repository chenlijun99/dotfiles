local M = {}

local MARKER = "REVIEWED"

-- Last-resort extension map for files that are never opened as buffers and whose
-- filetype neovim cannot detect. Kept intentionally small — commentstring lookup
-- (steps 1-2 below) covers all filetypes neovim knows natively.
local EXT_MAP = {
	lua = "-- ",
	py = "# ", sh = "# ", bash = "# ", zsh = "# ",
	nix = "# ", yaml = "# ", yml = "# ", toml = "# ", r = "# ", rb = "# ",
	js = "// ", ts = "// ", jsx = "// ", tsx = "// ",
	c = "// ", cpp = "// ", cc = "// ", cs = "// ",
	java = "// ", go = "// ", rs = "// ", swift = "// ", kt = "// ", scala = "// ",
	vim = '" ',
}

-- false = "filetype known but has no comment syntax" (sentinel to distinguish from uncached nil)
local _cs_cache = {}

local function commentstring_to_prefix(cs)
	if not cs or cs == "" or not cs:match("%%s") then return nil end
	return cs:match("^(.-)%%s")
end

-- Derive the comment prefix for a given neovim filetype name by asking a scratch
-- buffer to load the ftplugin. Results are cached per filetype.
local function prefix_for_ft(ft)
	local cached = _cs_cache[ft]
	if cached ~= nil then
		return cached ~= false and cached or nil
	end

	local tmp = vim.api.nvim_create_buf(false, true)
	local cs = ""
	vim.api.nvim_buf_call(tmp, function()
		-- Setting filetype triggers FileType autocmds (ftplugins) which set commentstring.
		-- buftype=nofile on the scratch buffer prevents LSP from attaching.
		vim.bo.filetype = ft
		cs = vim.bo.commentstring or ""
	end)
	vim.api.nvim_buf_delete(tmp, { force = true })

	local prefix = commentstring_to_prefix(cs)
	_cs_cache[ft] = prefix or false
	return prefix
end

-- Return the comment prefix string (e.g. "-- ", "# ", "// ") for filepath, or nil
-- if the file type genuinely has no comment syntax (e.g. JSON) or is unknown.
-- Detection priority:
--   1. commentstring of a loaded buffer (covers tree-sitter-enhanced ftplugins too)
--   2. neovim filetype detection by filename → commentstring via scratch buffer
--   3. extension map (fallback for rare cases)
--   4. nil  → caller adds the bare REVIEWED marker without a comment wrapper
function M.get_comment_prefix(filepath)
	-- 1. Buffer already loaded: use its live commentstring.
	local bufnr = vim.fn.bufnr(filepath)
	if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
		return commentstring_to_prefix(vim.bo[bufnr].commentstring)
		-- Returns nil for filetypes with empty commentstring (JSON etc.) — correct.
	end

	-- 2. Detect filetype by filename; derive commentstring via cached scratch buffer.
	local ft = vim.filetype.match({ filename = filepath })
	if ft then
		return prefix_for_ft(ft)
	end

	-- 3. Extension map for anything neovim cannot detect.
	local ext = filepath:match("%.([^./]+)$")
	if ext then
		return EXT_MAP[ext:lower()]
	end

	return nil
end

local function read_head(filepath)
	local ok, lines = pcall(vim.fn.readfile, filepath, "", 5)
	return ok and lines or {}
end

function M.is_reviewed(filepath)
	local head = read_head(filepath)
	for _, line in ipairs(head) do
		if line:match(MARKER) then
			return true
		end
	end
	return false
end

function M.set_reviewed(filepath, reviewed)
	local ok, lines = pcall(vim.fn.readfile, filepath)
	if not ok or not lines then
		vim.notify("review_tracker: cannot read " .. filepath, vim.log.levels.ERROR)
		return
	end

	if reviewed then
		local prefix = M.get_comment_prefix(filepath)
		-- prefix == nil means no known comment syntax: add bare marker
		local marker_line = prefix and (prefix .. MARKER) or MARKER
		local insert_at = (lines[1] and lines[1]:match("^#!")) and 2 or 1
		table.insert(lines, insert_at, marker_line)
	else
		for i = 1, math.min(5, #lines) do
			if lines[i] and lines[i]:match(MARKER) then
				table.remove(lines, i)
				break
			end
		end
	end

	local write_ok, err = pcall(vim.fn.writefile, lines, filepath)
	if not write_ok then
		vim.notify("review_tracker: write failed: " .. tostring(err), vim.log.levels.ERROR)
		return
	end

	local loaded_bufnr = vim.fn.bufnr(filepath)
	if loaded_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(loaded_bufnr) then
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(loaded_bufnr) then
				vim.api.nvim_buf_call(loaded_bufnr, function()
					vim.cmd("silent! checktime")
				end)
			end
		end)
	end
end

function M.toggle_reviewed(filepath)
	M.set_reviewed(filepath, not M.is_reviewed(filepath))
end

return M

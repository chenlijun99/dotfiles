local M = {}

M.core = require("review_tracker.core")

---@class ReviewTrackerIntegration
---@field resolve_file? fun(bufnr: integer): string|nil  Return the working-tree path for bufnr, or nil if not applicable
---@field on_toggle?    fun(filepath: string): nil        Called after a file's reviewed state changes

---@type ReviewTrackerIntegration[]
M._integrations = {}

function M.toggle_reviewed()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)

	-- Let integrations resolve the real working-tree file when we're in a
	-- special buffer (codediff explorer sidebar or virtual diff pane).
	local integration_resolved = false
	for _, integration in ipairs(M._integrations) do
		if integration.resolve_file then
			local resolved = integration.resolve_file(bufnr)
			if resolved then
				filepath = resolved
				integration_resolved = true
				break
			end
		end
	end

	-- When no integration resolved the path: bail for synthetic buffers
	-- (non-empty buftype = nofile/nowrite/...) and for truly empty names.
	if not filepath or filepath == "" then
		vim.notify("review_tracker: no file to mark", vim.log.levels.WARN)
		return
	end
	if not integration_resolved and vim.bo[bufnr].buftype ~= "" then
		vim.notify("review_tracker: no file to mark", vim.log.levels.WARN)
		return
	end

	M.core.toggle_reviewed(filepath)

	for _, integration in ipairs(M._integrations) do
		if integration.on_toggle then
			integration.on_toggle(filepath)
		end
	end
end

function M.setup(opts)
	opts = opts or {}
	local key = (opts.keys and opts.keys.toggle_reviewed) or "<leader>rv"
	vim.keymap.set("n", key, M.toggle_reviewed, { desc = "Toggle reviewed marker" })

	local codediff_ok, codediff = pcall(require, "review_tracker.integrations.codediff")
	if codediff_ok then
		codediff.setup()
		table.insert(M._integrations, codediff)
	end
end

return M

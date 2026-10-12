local plugin = vim.fn.getcwd() .. "/src/vim/local_plugins/review_tracker"
local codediff = vim.fn.expand("~/.local/share/nvim/lazy/codediff.nvim")
vim.opt.runtimepath:append({ plugin, codediff })

local sessions = {}
package.loaded["codediff.ui.lifecycle.session"] = {
	get_active_diffs = function() return sessions end,
}

local lifecycle = require("codediff.ui.lifecycle")
local integration = require("review_tracker.integrations.codediff")
local core = require("review_tracker.core")
local is_reviewed = core.is_reviewed
local tabpage = vim.api.nvim_get_current_tabpage()
local explorer_buf = vim.api.nvim_get_current_buf()
vim.bo[explorer_buf].filetype = "codediff-explorer"
vim.api.nvim_buf_set_lines(explorer_buf, 0, -1, false, { "file.lua" })
local original_buf = vim.api.nvim_create_buf(false, true)
local modified_buf = vim.api.nvim_create_buf(false, true)
local node = { data = { path = "file.lua" } }
local renders = 0
local explorer = {
	bufnr = explorer_buf,
	data = {
		git_root = "/tmp/review-tracker-test",
		current_file_path = "file.lua",
		status_result = { unstaged = { { path = "file.lua" } }, staged = {}, conflicts = {} },
	},
	tree = {
		get_node = function(_, line) return line == 1 and node or nil end,
		render = function() renders = renders + 1 end,
	},
}
sessions[tabpage] = {
	panel = { name = "explorer", view = explorer, data = explorer.data },
	original_bufnr = original_buf,
	modified_bufnr = modified_buf,
}
assert(lifecycle.get_panel_view(tabpage) == explorer)
core.is_reviewed = function(path)
	assert(path == "/tmp/review-tracker-test/file.lua", path)
	return true
end

assert(integration.resolve_file(explorer_buf) == "/tmp/review-tracker-test/file.lua", "explorer file resolution")
assert(integration.resolve_file(original_buf) == "/tmp/review-tracker-test/file.lua", "original pane file resolution")
assert(integration.resolve_file(modified_buf) == "/tmp/review-tracker-test/file.lua", "modified pane file resolution")

integration.decorate_explorer(tabpage)
local marks = vim.api.nvim_buf_get_extmarks(explorer_buf, vim.api.nvim_get_namespaces().review_tracker_codediff, 0, -1, {})
assert(#marks == 1, "reviewed file decoration")

local progress
vim.notify = function(message) progress = message end
integration.show_progress()
assert(progress and progress:find("Review progress: 1 / 1", 1, true), "review progress")

integration.setup()
vim.api.nvim_exec_autocmds("User", { pattern = "CodeDiffFileSelect", data = { tabpage = tabpage } })
vim.api.nvim_buf_clear_namespace(explorer_buf, vim.api.nvim_get_namespaces().review_tracker_codediff, 0, -1)
explorer.tree:render()
vim.wait(100, function()
	return renders == 1 and #vim.api.nvim_buf_get_extmarks(explorer_buf, vim.api.nvim_get_namespaces().review_tracker_codediff, 0, -1, {}) == 1
end)
assert(explorer._review_tracker_hooked, "explorer render hook")
assert(#vim.api.nvim_buf_get_extmarks(explorer_buf, vim.api.nvim_get_namespaces().review_tracker_codediff, 0, -1, {}) == 1, "decoration after render")

core.is_reviewed = is_reviewed
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "return 1" }, root .. "/one.lua")
vim.fn.writefile({ "-- REVIEWED", "return 2" }, root .. "/two.lua")
vim.fn.writefile({ "binary contents" }, root .. "/binary.dat")
local raw_fd = assert(vim.uv.fs_open(root .. "/raw.bin", "w", 420))
assert(vim.uv.fs_write(raw_fd, "raw\0bytes", 0))
vim.uv.fs_close(raw_fd)
explorer.data.git_root = root
explorer.data.status_result = {
	unstaged = { { path = "one.lua" }, { path = "two.lua" }, { path = "missing.lua", status = "D" }, { path = "binary.dat", line_stats = { binary = true } }, { path = "raw.bin" } },
	staged = { { path = "one.lua" } },
	conflicts = {},
}
vim.g.mapleader = " "
require("review_tracker").setup()
local bulk_mapping = vim.fn.maparg("<leader>rV", "n", false, true)
assert(type(bulk_mapping.callback) == "function", "bulk toggle mapping")
bulk_mapping.callback()
assert(core.is_reviewed(root .. "/one.lua") and core.is_reviewed(root .. "/two.lua"), "mark all reviewed")
assert(#vim.fn.readfile(root .. "/one.lua") == 2, "duplicate status entry is written once")
assert(#vim.fn.readfile(root .. "/two.lua") == 2, "already reviewed file is unchanged")
bulk_mapping.callback()
assert(not core.is_reviewed(root .. "/one.lua") and not core.is_reviewed(root .. "/two.lua"), "clear all reviewed")
assert(#vim.fn.readfile(root .. "/one.lua") == 1, "review marker is removed")
assert(vim.fn.filereadable(root .. "/missing.lua") == 0, "deleted file stays absent")
assert(vim.deep_equal(vim.fn.readfile(root .. "/binary.dat"), { "binary contents" }), "binary file is unchanged")
local raw_fd_read = assert(vim.uv.fs_open(root .. "/raw.bin", "r", 0))
assert(vim.uv.fs_read(raw_fd_read, 9, 0) == "raw\0bytes", "unlabelled binary file is unchanged")
vim.uv.fs_close(raw_fd_read)
vim.fn.delete(root, "rf")
print("review_tracker codediff integration: OK")

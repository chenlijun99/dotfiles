local bufnr = vim.api.nvim_get_current_buf()

local function opts(desc)
	return {
		desc = desc,
		noremap = true,
		silent = true,
		buffer = bufnr,
	}
end

vim.keymap.set("n", "<leader>la", function()
	vim.cmd.RustLsp("codeAction")
end, opts("Code action"))

vim.keymap.set("n", "<localleader>t", function()
	vim.cmd.RustLsp("testables")
end, opts("Testables"))
vim.keymap.set("n", "<localleader>T", function()
	vim.cmd.RustLsp({ "testables", bang = true })
end, opts("Last testable"))

vim.keymap.set("n", "<localleader>r", function()
	vim.cmd.RustLsp("runnables")
end, opts("Runnable"))

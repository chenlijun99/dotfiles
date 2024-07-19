local nvim_lsp = require("lspconfig")
-- Why not use .nvim.lua? Because with `exrc` `.nvim.lua` is looked up
-- only in the current directory and not the ancestor directories.
-- Thus if I open a file in a deep folder from Obsidian, I won't have all this
-- config.

-- An example nvim-lspconfig capabilities setting
local capabilities = require("cmp_nvim_lsp").default_capabilities(
	vim.lsp.protocol.make_client_capabilities()
)

-- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
-- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
capabilities.workspace = {
	didChangeWatchedFiles = {
		dynamicRegistration = true,
	},
}

-- Enable markdown_oxide of Obsidian vault
nvim_lsp.markdown_oxide.setup({
	capabilities = capabilities,
})
-- Call LspStart to make the newly set up LSP attach to the current buffer
vim.cmd("LspStart")

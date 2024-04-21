local nvim_lsp = require("lspconfig")
-- Why not use .nvim.lua? Because with `exrc` `.nvim.lua` is looked up
-- only in the current directory and not the ancestor directories.
-- Thus if I open a file in a deep folder from Obsidian, I won't have all this
-- config.

-- Enable markdown_oxide of Obsidian vault
nvim_lsp.markdown_oxide.setup{}
-- Call LspStart to make the newly set up LSP attach to the current buffer
vim.cmd("LspStart")

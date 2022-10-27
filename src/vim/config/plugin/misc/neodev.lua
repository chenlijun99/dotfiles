-- Provides more intellisense when editing neovim lua config files
Plug("folke/neodev.nvim", {
	config = function()
		local neodev = require("neodev").setup({})

		local lspconfig = require("lspconfig")
		lspconfig.sumneko_lua.setup(neodev)
	end,
})

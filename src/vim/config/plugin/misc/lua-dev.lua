-- Provides more intellisense when editing neovim lua config files
Plug("folke/lua-dev.nvim", {
	config = function()
		local luadev = require("lua-dev").setup({})

		local lspconfig = require("lspconfig")
		lspconfig.sumneko_lua.setup(luadev)
	end,
})

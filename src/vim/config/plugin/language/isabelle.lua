return {
	{
		"Treeniks/isabelle-lsp.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("isabelle-lsp").setup({})
			local lspconfig = require("lspconfig")
			lspconfig.isabelle.setup({})
		end,
	},
}

return {
	{
		"Treeniks/isabelle-lsp.nvim",
		lazy = true,
		ft = "isabelle",
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

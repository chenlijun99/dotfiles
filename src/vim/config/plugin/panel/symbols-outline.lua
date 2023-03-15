return {
	{
		"simrat39/symbols-outline.nvim",
		keys = {
			{
				"<leader>ps",
				"<cmd>SymbolsOutlineOpen<CR>",
				desc = "Symbols outline",
			},
		},
		config = function()
			require("symbols-outline").setup()
		end,
	},
}

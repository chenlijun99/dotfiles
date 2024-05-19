return {
	{
		"stevearc/aerial.nvim",
		keys = {
			{
				"<leader>ps",
				"<cmd>AerialToggle!<CR>",
				desc = "Symbols outline",
			},
		},
		opts = {},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
}

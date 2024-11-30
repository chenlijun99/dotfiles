return {
	{
		"stevearc/aerial.nvim",
		lazy = true,
		keys = {
			{
				"<leader>pS",
				"<cmd>AerialNavOpen<CR>",
				desc = "Symbols navigation",
			},
			{
				"<leader>ps",
				"<cmd>AerialToggle!<CR>",
				desc = "Symbols outline",
			},
			{
				"<leader>fs",
				"<cmd>call aerial#fzf()<cr>",
				desc = "Fuzzy file symbols",
			},
		},
		opts = {
			nav = {
				preview = true,
			},
			layout = {
				-- These control the width of the aerial window.
				-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a list of mixed types.
				-- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
				max_width = { 50, 0.5 },
				width = nil,
				min_width = 10,
			},
		},
		config = function(_, opts)
			local aerial = require("aerial")
			aerial.setup(opts)

			-- aerial#fzf() doesn't property initialize aerial
			-- like the other commands (e.g. AerialToggle) do.
			-- So if after opening nvim we just it before doing anything
			-- else with aerial, an error is raise.
			-- This function also takes care to initialize aerial.
			aerial.info()
		end,
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
}

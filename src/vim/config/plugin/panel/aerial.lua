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
				"<c-m>",
				"<cmd>call aerial#fzf()<cr>",
				desc = "Fuzzy file symbols",
			},
		},
		opts = { nav = {
			preview = true,
		} },
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

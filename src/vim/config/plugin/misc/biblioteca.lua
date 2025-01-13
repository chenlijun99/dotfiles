return {
	{
		"chenlijun99/biblioteca.nvim",
		build = "./install.sh",
		dependencies = { "nvim-lua/plenary.nvim", "L3MON4D3/LuaSnip" },
		config = function()
			require("biblioteca").setup()
			require("biblioteca.integrations.luasnip").setup({})
		end,
		keys = {
			{
				"<leader>fb",
				function()
					require("biblioteca.pickers.fzf_lua").bibliography()
				end,
				desc = "Fuzzy search bibliography",
			},
		},
	},
}

Plug("simrat39/symbols-outline.nvim", {
	config = function()
		which_key_map.p.s = "Symbols outline"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>ps",
			"<cmd>SymbolsOutlineOpen<CR>",
			{ noremap = true }
		)
		require("symbols-outline").setup()
	end,
})

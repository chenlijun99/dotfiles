Plug("phaazon/hop.nvim", {
	config = function()
		require("hop").setup()

		which_key_map.j = "Jump"
		local opts = { noremap = true, silent = true }
		vim.api.nvim_set_keymap("", "f", "<cmd>HopChar1<CR>", opts)
		vim.api.nvim_set_keymap("n", "f", "<cmd>HopChar1MW<CR>", opts)
	end,
})

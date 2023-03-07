return {
	{
		"phaazon/hop.nvim",
		config = function()
			require("hop").setup()

			which_key_map.j = "Jump"
			local opts = { noremap = true, silent = true }
			vim.api.nvim_set_keymap("", "<leader>j", "<cmd>HopChar1<CR>", opts)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>j",
				"<cmd>HopChar1MW<CR>",
				opts
			)
		end,
	},
}

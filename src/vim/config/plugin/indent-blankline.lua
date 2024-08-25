return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		lazy = true,
		event = "LazyFile",
		config = function()
			require("ibl").setup({
				scope = {
					-- Don't show underlines. It's just confusing
					show_start = false,
					show_end = false,
				}
			})
		end,
	},
}

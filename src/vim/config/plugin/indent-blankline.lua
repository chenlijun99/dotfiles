return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		lazy = true,
		event = "LazyFile",
		config = function()
			require("ibl").setup({})
		end,
	},
}

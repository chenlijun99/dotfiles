return {
	{
		dir = vim.fn.expand("~/.vim/local_plugins/review_tracker"),
		name = "review_tracker",
		config = function()
			require("review_tracker").setup()
		end,
	},
}

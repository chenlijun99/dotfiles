return {
	{
		dir = vim.fn.expand("~/.vim/local_plugins/review_session"),
		name = "review_session",
		config = function()
			require("review_session").setup()
		end,
	},
}

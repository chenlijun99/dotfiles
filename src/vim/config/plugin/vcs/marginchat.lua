local root = vim.fn.expand("~/Repositories/personal/marginchat")

return {
	{
		dir = root .. "/apps/marginchat-nvim",
		name = "marginchat",
		dev = true,
		config = function()
			require("marginchat").setup({
				cli = {
					executable = root .. "/bin/marginchat",
				},
			})
		end,
	},
}

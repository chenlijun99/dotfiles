local profile = require("clj.profile")
if not profile.is("full") then return {} end

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

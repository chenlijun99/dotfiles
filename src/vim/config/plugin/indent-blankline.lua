local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		lazy = true,
		event = "LazyFile",
		config = function()
			local ibl = require("ibl")
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.ACTIVE, function(bufnr)
				return not vim.b[bufnr].clj_large_file
			end)
			ibl.setup({
				scope = {
					-- Don't show underlines. It's just confusing
					show_start = false,
					show_end = false,
				}
			})
		end,
	},
}

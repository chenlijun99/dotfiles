local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<c-\>]],
				-- When entering a terminal, always enter in insert mode.
				persist_mode = false,
				direction = "float",
			})
		end,
	},
}

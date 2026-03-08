local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	cmd = "PasteImage",
	opts = {
		default = {
			dir_path = function()
				-- Put images in assets folder of the current buffer
				return vim.fn.expand("%:r") .. ".assets/"
			end,
		},
	},
}

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

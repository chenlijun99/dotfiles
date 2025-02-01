return {
	-- Some eye-candy. Not so useful, but perhaps sometimes when having
	-- files with a lot of links, it can be useful.
	-- Doesn't work very well with `:set wrap`. Especially in large code blocks.
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<localleader>l",
				"<cmd>Markview toggle<cr>",
				ft = "markdown",
				desc = "Toggle markview preview",
			},
		},
		config = function()
			local presets = require("markview.presets")

			require("markview").setup({
				preview = {
					-- Keep initially disabled. I'll enable it when I need.
					enable = false,
				},
				--hybrid_modes = {"i"},
				markdown = {
					headings = presets.headings.marker,
					list_items = {
						enable = true,
						marker_minus = {
							add_padding = false,
						},
						marker_plus = {
							add_padding = false,
						},
						marker_star = {
							add_padding = false,
						},
						marker_dot = {
							add_padding = false,
						},
						marker_parenthesis = {
							add_padding = false,
						},
					},
				},
				inline_codes = {
					enable = true,
				},
				latex = {
					enable = true,
				},
			})
		end,
	},
	-- TODO: Latex inline preview
	-- https://www.reddit.com/r/neovim/comments/1hqjyc0/plugin_to_render_latex_block_equations_in_neovim/
	-- https://github.com/Thiago4532/mdmath.nvim
	-- https://github.com/Prometheus1400/markdown-latex-render.nvim/

	-- TOOD: inline image preview.
	-- Had some problems installing the necessary dependencies on Nixos
	--{
	--{
	--"3rd/image.nvim",
	--opts = {
	--processor = "magick_cli",
	--},
	--},
	--},
}

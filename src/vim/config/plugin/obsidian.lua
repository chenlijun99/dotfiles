return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
		-- see below for full list of optional dependencies 👇
	},
	opts = {
		workspaces = {
			{
				name = "root",
				path = function()
					return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
				end,
			},
		},
		-- Optional, boolean or a function that takes a filename and returns a boolean.
		-- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
		disable_frontmatter = true,
		ui = {
			-- set to false to disable all additional syntax features
			enable = false,
		},
		completion = {
			-- I already have markdown-oxide for this
			nvim_cmp = false,
		},

		-- see below for full list of options 👇
	},
}

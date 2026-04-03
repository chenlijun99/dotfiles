return {
	-- git signs
	{
		"lewis6991/gitsigns.nvim",
		event = "LazyFile",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = function(bufnr)
				if vim.b[bufnr].clj_large_file then
					return false
				end

				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				local function opts(desc)
					return {
						desc = "LSP: " .. desc,
						noremap = true,
					}
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next", { target = "all" })
					end
				end, opts("Next Git diff chunk"))

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev", { target = "all" })
					end
				end, opts("Previous Git diff chunk"))
			end,
		},
	},
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",

		opts = {
			-- Highlight configuration
			highlights = {
				line_insert = "DiffAdd",
				line_delete = "DiffDelete",

				char_brightness = 0.7,
			},

			-- Explorer panel configuration
			explorer = {
				position = "bottom",
				height = 8,
				-- Jump to modified pane after selecting a file
				focus_on_select = true,
				view_mode = "tree",
				flatten_dirs = true,
			},

			-- History panel configuration (for :CodeDiff history)
			history = {
				position = "bottom", -- "left" or "bottom" (default: bottom)
				height = 15, -- Height when position is "bottom" (lines)
				initial_focus = "history", -- Initial focus: "history", "original", or "modified"
				view_mode = "list", -- "list" or "tree" for files under commits
			},

			-- Keymaps in diff view
			keymaps = {
				view = {
					quit = "Q",
				},
			},
		},
	},
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		opts = {
			-- or "fzf-lua" or "snacks" or "default"
			picker = "fzf-lua",
			-- bare Octo command opens picker of commands
			enable_builtin = true,
			-- use local files on right side of reviews
			-- So that they are normal buffers where LSP and everything else works
			use_local_fs = true,
		},
		keys = {
			{
				"<leader>gh",
				"<CMD>Octo<CR>",
				desc = "Run Octo",
			},
			{
				"<leader>ghi",
				"<CMD>Octo issue list<CR>",
				desc = "List GitHub Issues",
			},
			{
				"<leader>ghp",
				"<CMD>Octo pr list<CR>",
				desc = "List GitHub PullRequests",
			},
			{
				"<leader>ghd",
				"<CMD>Octo discussion list<CR>",
				desc = "List GitHub Discussions",
			},
			{
				"<leader>ghn",
				"<CMD>Octo notification list<CR>",
				desc = "List GitHub Notifications",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"ibhagwan/fzf-lua",
			"nvim-tree/nvim-web-devicons",
		},
	},
}

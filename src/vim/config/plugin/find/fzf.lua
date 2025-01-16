return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<c-p>",
			function()
				local in_git = vim.api.nvim_eval(
					"exists('*FugitiveHead') && !empty(FugitiveHead())"
				)
				if in_git then
					require("fzf-lua").files()
				else
					require("fzf-lua").git_files()
				end
			end,
			desc = "fuzzy files",
		},
		{
			"<c-f>",
			function()
				require("fzf-lua").grep_project()
			end,
			desc = "fuzzy search",
		},
		{
			"<c-b>",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "fuzzy buffers",
		},
		{
			"<leader>fp",
			function()
				require("fzf-lua").files()
			end,
			desc = "fuzzy files",
		},
		{
			"<leader>fP",
			function()
				require("fzf-lua").git_files({
					cmd = "git ls-files --exclude-standard --recurse-submodules",
				})
			end,
			desc = "fuzzy git (+submodules)",
		},
		{
			"<leader>ft",
			function()
				require("fzf-lua").tags()
			end,
			desc = "fuzzy tags",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").git_commits()
			end,
			desc = "fuzzy commits",
		},
		{
			"<leader>fls",
			function()
				require("fzf-lua").lsp_document_symbols()
			end,
			desc = "Document symbols",
		},
		{
			"<leader>flS",
			function()
				require("fzf-lua").lsp_live_workspace_symbols()
			end,
			desc = "Workspace symbols",
		},
	},
	lazy = true,
	opts = {
		winopts = {
			preview = {
				layout = "vertical",
			},
		},
		keymap = {
			fzf = {
				["ctrl-N"] = "next-history",
				["ctrl-P"] = "prev-history",
			},
		},
		fzf_opts = {
			["--history"] = vim.fn.stdpath("data") .. "/fzf-history",
		},
	},
}

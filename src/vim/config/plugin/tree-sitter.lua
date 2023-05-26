return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				{
					"nvim-treesitter/playground",
					config = function(_, opts)
						require("nvim-treesitter.configs").setup(opts)
					end,
				},
			},
		},
		---@type TSConfig
		opts = {
			highlight = { enable = true },
			indent = { enable = true, disable = { "python" } },
			context_commentstring = { enable = true, enable_autocmd = false },
			ensure_installed = {
				"bash",
				"bibtex",
				"c",
				"cmake",
				"comment",
				"commonlisp",
				"cpp",
				"css",
				"dart",
				"devicetree",
				"dockerfile",
				"dot",
				"erlang",
				"graphql",
				"html",
				"http",
				"java",
				"javascript",
				"jsdoc",
				"json",
				"json5",
				"llvm",
				"lua",
				"make",
				"markdown",
				"ninja",
				"nix",
				"python",
				"query",
				"regex",
				"rust",
				"scala",
				"scss",
				"todotxt",
				"toml",
				"tlaplus",
				"tsx",
				"typescript",
				"verilog",
				"vim",
				"vue",
				"yaml",
				"kotlin",
				-- VimTex provides better highlighting
				--"latex",
			},
		},
		---@param opts TSConfig
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}

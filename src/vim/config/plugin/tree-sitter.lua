return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "LazyFile", "VeryLazy" },
		lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
		---@type TSConfig
		opts = {
			highlight = {
				enable = true,
				disable = function(lang, bufnr)
					-- Disable tree-sitter hilight on large files
					return vim.api.nvim_buf_line_count(bufnr) > 5000
				end,
			},
			indent = {
				enable = true,
				disable = function(lang, bufnr)
					-- Disable tree-sitter indent on large files
					-- I actually most often just use external auto-formatter.
					-- So I may consider to disable tree-sitter indent entirely
					return lang == "python"
						or vim.api.nvim_buf_line_count(bufnr) > 5000
				end,
			},
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
				"ocaml",
				"ocaml_interface",
				"ocamllex",
				"rst",
				"ledger",
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

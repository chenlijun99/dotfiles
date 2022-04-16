Plug("nvim-treesitter/nvim-treesitter", {
	run = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
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
				"latex",
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
			},
			highlight = {
				enable = true,
				disable = {
					"vim",
					-- typescript is very slow with treesitter
					"typescript",
					"tsx",
					"tex",
					"cmake",
				},
			},
			indent = {
				enable = true,
				disable = {
					"vim",
					-- typescript is very slow with treesitter
					"typescript",
					"tsx",
					"tex",
					"cmake",
				},
			},
		})
	end,
})
Plug("nvim-treesitter/playground", {
	config = function()
		require("nvim-treesitter.configs").setup({
			playground = {
				enable = true,
				disable = {},
				-- Debounced time for highlighting nodes in the playground from source code
				updatetime = 25,
				-- Whether the query persists across vim sessions
				persist_queries = false,
				keybindings = {
					toggle_query_editor = "o",
					toggle_hl_groups = "i",
					toggle_injected_languages = "t",
					toggle_anonymous_nodes = "a",
					toggle_language_display = "I",
					focus_language = "f",
					unfocus_language = "F",
					update = "R",
					goto_node = "<cr>",
					show_help = "?",
				},
			},
		})
	end,
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		version = false,
		build = ":TSUpdate",
		event = { "LazyFile", "VeryLazy" },
		-- load treesitter early when opening a file from the cmdline
		lazy = vim.fn.argc(-1) == 0,
		config = function()
			-- Use HCL grammar for the opentofu filetype
			vim.treesitter.language.register("hcl", "opentofu")

			local ts = require("nvim-treesitter")

			local ensure_installed = {
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
				"vim",
				"vue",
				"yaml",
				"kotlin",
				"ocaml",
				"ocaml_interface",
				"ocamllex",
				"rst",
				"ledger",
				"typst",
				"just",
				"latex",
				"hcl",
				"sql",
			}
			ts.install(ensure_installed)

			local ignore_filetype = {
				"checkhealth",
				"lazy",
				"mason",
				"snacks_dashboard",
				"snacks_notif",
				"snacks_win",
				"snacks_input",
				"snacks_picker_input",
				"TelescopePrompt",
				"alpha",
				"dashboard",
				"spectre_panel",
				"NvimTree",
				"undotree",
				"Outline",
				"sagaoutline",
				"copilot-chat",
				"vscode-diff-explorer",
			}

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup(
					"TreesitterSetup",
					{ clear = true }
				),
				desc = "Enable TreeSitter highlighting",
				callback = function(ev)
					local ft = ev.match
					if vim.tbl_contains(ignore_filetype, ft) then
						return
					end

					local lang = vim.treesitter.language.get_lang(ft) or ft
					local buf = ev.buf

					if
						-- VimTex provides better highlighting
						lang == "latex"
					then
						return
					end

					pcall(vim.treesitter.start, buf, lang)
				end,
			})
		end,
	},
}

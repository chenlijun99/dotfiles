return {
	{
		"stevearc/conform.nvim",
		lazy = true,
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({
						timeout_ms = 3000,
						lsp_format = "fallback",
					})
				end,
				mode = { "n", "v" },
				desc = "Conform: format",
			},
			{
				"<leader>lF",
				function()
					require("conform").format({
						timeout_ms = 3000,
						formatters = { "injected" },
					})
				end,
				mode = { "n", "v" },
				desc = "Conform: format",
			},
		},
		opts = {
			formatters_by_ft = {
				nix = { "alejandra" },
				lua = { "stylua" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				asm = { "asm-fmt" },
				sh = { "shfmt" },
				cmake = { "cmake_format" },
				python = { "black" },
				typst = { "typstyle" },
				json = { "fixjson" },
				-- fixjson doesn't support comments yet
				-- https://github.com/rhysd/fixjson/issues/17
				-- jsonc = { "fixjson" },
				just = { "just" },
				toml = { "taplo" },
				markdown = {
					-- Prefer markdownlint as formatter.
					-- We use it as linter anyway.
					"markdownlint-cli2",
					-- I don't like how prettier formats the lists.
					--
					-- It has been fixed in 3.4.0.
					-- See https://github.com/prettier/prettier/issues/5019
					-- But at the time of writing, it is still not available
					-- on Nixpkgs.
					"prettierd",
					"prettier",
					stop_after_first = true,
				},
				javascript = {
					"prettierd",
					"prettier",
					stop_after_first = true,
				},
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
}

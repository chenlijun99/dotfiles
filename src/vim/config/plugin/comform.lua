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
				markdown = {
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

return {
	{
		"mfussenegger/nvim-lint",
		event = "LazyFile",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				markdown = {
					-- See
					-- https://dlaa.me/blog/post/markdownlintcli2
					-- for markdownlint-cli vs markdownlint-cli2
					"markdownlint-cli2" 
				},
				shell = { "shellcheck" },
				yaml = { "yamllint" },
				zsh = { "zsh" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				css = { "stylelint" },
				sass = { "stylelint" },
				scss = { "stylelint" },
				lua = { "luacheck" },
			}

			local M = {}

			function M.debounce(ms, fn)
				local timer = vim.uv.new_timer()
				return function(...)
					local argv = { ... }
					timer:start(ms, 0, function()
						timer:stop()
						vim.schedule_wrap(fn)(unpack(argv))
					end)
				end
			end

			vim.api.nvim_create_autocmd(
				{ "BufWritePost", "BufReadPost", "InsertLeave" },
				{
					group = vim.api.nvim_create_augroup(
						"nvim-lint",
						{ clear = true }
					),
					callback = M.debounce(100, function()
						lint.try_lint()
					end),
				}
			)
		end,
	},
}

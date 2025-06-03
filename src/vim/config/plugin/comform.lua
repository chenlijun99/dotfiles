-- Taken from https://github.com/stevearc/conform.nvim/issues/92#issuecomment-2077222348
function format_diff()
	local ignore_filetypes = { "lua" }
	if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
		vim.notify(
			"range formatting for "
				.. vim.bo.filetype
				.. " not working properly."
		)
		return
	end

	local hunks = require("gitsigns").get_hunks()
	local format = require("conform").format
	for i = #hunks, 1, -1 do
		local hunk = hunks[i]
		if hunk ~= nil and hunk.type ~= "delete" then
			local start = hunk.added.start
			local last = start + hunk.added.count
			-- nvim_buf_get_lines uses zero-based indexing -> subtract from last
			local last_hunk_line =
				vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
			local range = {
				start = { start, 0 },
				["end"] = { last - 1, last_hunk_line:len() },
			}
			format({ range = range })
		end
	end
end
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
				"<leader>gf",
				function()
					format_diff()
				end,
				mode = { "n" },
				desc = "Conform: format git changes",
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
					"markdownlint",
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
				yaml = {
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

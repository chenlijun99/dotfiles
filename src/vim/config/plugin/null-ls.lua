Plug("nvim-lua/plenary.nvim")
Plug("jose-elias-alvarez/null-ls.nvim", {
	config = function()
		local null_ls = require("null-ls")
		local h = require("null-ls.helpers")
		local methods = require("null-ls.methods")

		local FORMATTING = methods.internal.FORMATTING

		alejandra = h.make_builtin({
			name = "alejandra",
			meta = {
				url = "https://github.com/kamadorueda/alejandra",
				description = " The Uncompromising Nix Code Formatter ",
			},
			method = FORMATTING,
			filetypes = { "nix" },
			generator_opts = {
				command = "alejandra",
				to_stdin = true,
			},
			factory = h.formatter_factory,
		})

		null_ls.setup({
			sources = {
				-- formatters
				alejandra,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettierd,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.asmfmt,
				null_ls.builtins.formatting.cmake_format,
				null_ls.builtins.formatting.eslint_d,
				null_ls.builtins.formatting.latexindent,
				null_ls.builtins.formatting.markdownlint,
				null_ls.builtins.formatting.stylelint,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.trim_newlines,
				null_ls.builtins.formatting.trim_whitespace,
				null_ls.builtins.formatting.shfmt,
				-- code actions
				null_ls.builtins.code_actions.eslint_d,
				null_ls.builtins.code_actions.proselint,
				null_ls.builtins.code_actions.shellcheck,
				-- hover
				null_ls.builtins.hover.dictionary,
				-- diagnostics
				null_ls.builtins.diagnostics.cppcheck,
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.diagnostics.luacheck,
				null_ls.builtins.diagnostics.markdownlint,
				null_ls.builtins.diagnostics.protoc_gen_lint,
				null_ls.builtins.diagnostics.shellcheck,
				null_ls.builtins.diagnostics.stylelint,
				null_ls.builtins.diagnostics.tsc,
				null_ls.builtins.diagnostics.yamllint,
				null_ls.builtins.diagnostics.zsh,
			},
		})
	end,
})

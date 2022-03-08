Plug("nvim-lua/plenary.nvim")
Plug("jose-elias-alvarez/null-ls.nvim", {
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				-- formatters
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettierd,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.asmfmt,
				null_ls.builtins.formatting.cmake_format,
				null_ls.builtins.formatting.eslint_d,
				null_ls.builtins.formatting.latexindent,
				null_ls.builtins.formatting.lua_format,
				null_ls.builtins.formatting.markdownlint,
				null_ls.builtins.formatting.stylelint,
				null_ls.builtins.formatting.trim_newlines,
				null_ls.builtins.formatting.trim_whitespace,
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

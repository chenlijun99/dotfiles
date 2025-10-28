return {
	{
		"AlexandrosAlexiou/kotlin.nvim",
		ft = { "kotlin" },
		dependencies = { "oil.nvim" },
		config = function()
			-- Check if kotlin-lsp is installed in the PATH
			local kotlin_lsp_path = vim.fn.exepath("kotlin-lsp")
			if kotlin_lsp_path ~= "" then
				local lsp_bin_dir = vim.fn.fnamemodify(kotlin_lsp_path, ":h")
				local parent_dir = vim.fn.fnamemodify(lsp_bin_dir, ":h")
				local lsp_lib_dir = parent_dir .. "/lib"
				if vim.fn.isdirectory(lsp_lib_dir) == 1 then
					vim.env.KOTLIN_LSP_DIR = parent_dir
				end
			end

			require("kotlin").setup({
				-- Optional: Specify root markers for multi-module projects
				root_markers = {
					"gradlew",
					".git",
					"mvnw",
					"settings.gradle",
				},
			})
		end,
	},
}

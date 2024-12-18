return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			local function getWords()
				if
					vim.bo.filetype == "markdown"
					or vim.bo.filetype == "txt"
					or vim.bo.filetype == "latex"
				then
					return tostring(vim.fn.wordcount().words) .. " words"
				else
					return ""
				end
			end

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {},
					always_divide_middle = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						"diff",
						"diagnostics",
					},
					lualine_c = { "filename" },
					lualine_x = {
						getWords,
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},
}

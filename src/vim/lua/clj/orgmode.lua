local M = {}

function M.get_orgmode_plugin_lazy_nvim(config)
	return {
		"nvim-orgmode/orgmode",
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		event = "VeryLazy",
		ft = { "org" },
		config = function()
			local default_config = {
				org_deadline_warning_days = 14,
				mappings = {
					disable_all = false,
					org_return_uses_meta_return = false,
					prefix = "<localleader>o",
				},
			}

			require("orgmode").setup(
				vim.tbl_extend("force", default_config, config)
			)

			-- Modify nvim-cmp config to add source
			-- See [how can i append new sources to nvim-cmp configurations after cmp.setup](https://github.com/hrsh7th/nvim-cmp/discussions/670)
			local cmp = require("cmp")
			local config = cmp.get_config()
			table.insert(config.sources, {
				name = "orgmode",
			})
			cmp.setup(config)
		end,
	}
end

return M

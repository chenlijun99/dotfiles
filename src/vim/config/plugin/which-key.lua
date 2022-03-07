Plug("folke/which-key.nvim", {
	event = "BufWinEnter",
	config = function()
		local wk = require("which-key")
		wk.setup({
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		})
		local global_normap_mappings = vim.tbl_deep_extend(
			"error",
			which_key_map,
			vim.g.which_key_map
		)
		wk.register(global_normap_mappings, { prefix = "<leader>" })

		local global_normap_mappings_with_g_leader = vim.tbl_deep_extend(
			"error",
			which_key_map_g,
			vim.g.which_key_map_g
		)
		wk.register(global_normap_mappings_with_g_leader, { prefix = "g" })

		local global_normap_mappings_next = vim.tbl_deep_extend(
			"error",
			which_key_map_global_next,
			vim.g.which_key_map_global_next
		)
		wk.register(global_normap_mappings_next, { prefix = "]" })

		local global_normap_mappings_previous = vim.tbl_deep_extend(
			"error",
			which_key_map_global_previous,
			vim.g.which_key_map_global_previous
		)
		wk.register(global_normap_mappings_previous, { prefix = "[" })
	end,
})

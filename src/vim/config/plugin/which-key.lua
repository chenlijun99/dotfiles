return {
	{
		"folke/which-key.nvim",
		lazy = true,
		event = "VeryLazy",
		config = function(_, opts)
			local wk = require("which-key")

			wk.setup(opts)
			local function concatenate_in_place(dst, src)
				for _, v in pairs(src) do
					table.insert(dst, v)
				end
			end

			local function convert_to_spec(which_key_map, prefix)
				local spec = {}

				if which_key_map["map_name"] ~= nil then
					table.insert(spec, {
						prefix,
						desc = which_key_map["map_name"],
						mode = which_key_map["mode"] or { "n" },
					})
				end

				if which_key_map["group_name"] ~= nil then
					table.insert(spec, {
						prefix,
						group = which_key_map["group_name"],
						mode = which_key_map["mode"] or { "n", "v" },
					})
				end

				for k, v in pairs(which_key_map) do
					if type(v) == "table" then
						concatenate_in_place(
							spec,
							convert_to_spec(v, prefix .. k)
						)
					else
						if k ~= "group_name" and k ~= "map_name" then
							table.insert(spec, { prefix .. k, desc = v })
						end
					end
				end
				return spec
			end

			wk.add(convert_to_spec(vim.g.which_key_map, "<leader>"))
			wk.add(convert_to_spec(vim.g.which_key_map_g, "g"))
			wk.add(convert_to_spec(vim.g.which_key_map_global_next, "]"))
			wk.add(convert_to_spec(vim.g.which_key_map_global_previous, "["))
		end,
	},
}

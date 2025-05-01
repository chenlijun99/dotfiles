local M = {}

function M.get_leetcode_plugin_lazy_nvim(override_config)
	return {
		"kawre/leetcode.nvim",
		dependencies = {
			"ibhagwan/fzf-lua",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			local default_config = {
				injector = {
					["cpp"] = {
						before = {
							"#include <bits/stdc++.h>",
							"using namespace std;",
						},
						after = "int main() {}",
					},
				},
			}
			require("leetcode").setup(
				vim.tbl_extend("force", default_config, override_config)
			)

			local function opts(desc)
				return {
					desc = "Leetcode: " .. desc,
					noremap = true,
				}
			end
			vim.api.nvim_set_keymap("n", "<localleader>l", ":Leet ", opts(""))
		end,
	}
end

return M

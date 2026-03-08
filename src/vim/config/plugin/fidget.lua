local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	{
		"j-hui/fidget.nvim",
		opts = {
			notification = {
				override_vim_notify = true, -- Automatically override vim.notify() with Fidget
			},
		},
	},
}

local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	{
		"danymat/neogen",
		config = true,
		keys = {
			{
				"<leader>kg",
				function()
					require("neogen").generate()
				end,
				mode = { "n" },
				desc = "Generate doc (neogen)",
			},
		},
	},
}

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

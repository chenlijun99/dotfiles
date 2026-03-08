local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		config = function() end,
	},
}

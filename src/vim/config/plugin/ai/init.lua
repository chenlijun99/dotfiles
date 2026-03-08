local profile = require("clj.profile")
if not profile.is("full") then return {} end

return {
	{
		-- I use it just to set up the authentication token
		-- For the rest I use codecompanion.
		"github/copilot.vim",
		cmd = "Copilot",
	},
	{ import = "clj.plugin.ai.codecompanion" },
	{ import = "clj.plugin.ai.mcphub" },
}

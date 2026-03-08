local profile = require("clj.profile")

local specs = {
	{ import = "clj.plugin.misc.plenary" },
}

if profile.is("full") then
	vim.list_extend(specs, {
		{ import = "clj.plugin.misc.startuptime" },
		{ import = "clj.plugin.misc.biblioteca" },
		{ import = "clj.plugin.misc.nvim-highlight-colors" },
	})
end

return specs

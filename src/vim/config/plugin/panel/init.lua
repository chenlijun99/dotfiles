local profile = require("clj.profile")

local specs = {
	{ import = "clj.plugin.panel.nvim-tree" },
}

if profile.is("full") then
	vim.list_extend(specs, {
		{ import = "clj.plugin.panel.aerial" },
	})
end

return specs

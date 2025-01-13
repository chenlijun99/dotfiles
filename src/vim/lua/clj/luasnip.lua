local luasnip = require("luasnip")

local M = {}

--- Utility function to programmatically expand a snippet given the name of the trigger
---@param trigger string
function M.expand_by_trigger(trigger, opts)
	local snip = nil
	for _, snippets in pairs(luasnip.get_snippets()) do
		for _, snippet in ipairs(snippets) do
			if snippet.trigger == trigger then
				snip = snippet
			end
		end
	end

	if snip then
		luasnip.snip_expand(snip, opts)
	end
end

return M

local M = {}

-- Resolve the active profile at startup.
-- Priority: $VIM_CLJ_PROFILE env var > ~/.local/state/nvim/profile file > "minimal"
local function detect_profile()
	local env = vim.env.VIM_CLJ_PROFILE
	if env and env ~= "" then
		return vim.trim(env)
	end

	local path = vim.fn.stdpath("state") .. "/profile"
	local f = io.open(path, "r")
	if f then
		local line = f:read("*l")
		f:close()
		if line then
			return vim.trim(line)
		end
	end

	return "minimal"
end

M.current = detect_profile()

--- Returns true when the active profile matches the given label.
---@param profile string
---@return boolean
function M.is(profile)
	return M.current == profile
end

return M

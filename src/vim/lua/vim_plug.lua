--[[
Vim plug wrapper to facilitate working with it in Luao
Mostly copied from https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom

The exposes Plug can be used in the same way of the normal Plug command
of vim-plug, with the following differences:

* Modifed option keys:
	* use `run` instead of `do`: do is a reserved keyword in lua
	* use `ft` instead of `for`: for is a reserved keyword in lua
* Added options:
	* config (optional): lua function that will be executed on plugin load
	* event (string or list, optional): lazy load plugin on autocmd trigger
--]]

local configs = {
	lazy = {},
	start = {},
}

local Plug = {
	-- "end" is a keyword, need something else
	after_plug_end = function()
		vim.fn["plug#end"]()

		for i, config in pairs(configs.start) do
			config()
		end
	end,
}

-- Not a fan of global functions, but it'll work better
-- for the people that will copy/paste this
_G.VimPlugApplyConfig = function(plugin_name)
	local fn = configs.lazy[plugin_name]
	if type(fn) == "function" then
		fn()
	end
end

local plug_name = function(repo)
	return repo:match("^[%w-]+/([%w-_.]+)$")
end

-- "Meta-functions"
local meta = {

	-- Function call "operation"
	__call = function(self, repo, opts)
		opts = opts or vim.empty_dict()

		-- we declare some aliases for `do` and `for`
		opts["do"] = opts.run
		opts.run = nil

		opts["for"] = opts.ft
		opts.ft = nil

		if opts.event then
			-- if event is defined, on must be empty
			opts["on"] = {}
		end

		vim.call("plug#", repo, opts)

		-- Add basic support to colocate plugin config
		if type(opts.config) == "function" then
			local plugin = opts.as or plug_name(repo)

			if opts["for"] == nil and opts.on == nil and opts.event == nil then
				configs.start[plugin] = opts.config
			else
				configs.lazy[plugin] = opts.config

				if opts.event then
					local autocmds = opts.event
					if type(opts.event) == "table" then
						autocmds = table.concat(opts.event, ",")
					end
					local load_cmd =
						[[ autocmd! %s * ++once call plug#load("%s") ]]
					vim.cmd(load_cmd:format(autocmds, plugin))
				end

				local user_cmd =
					[[ autocmd! User %s ++once lua VimPlugApplyConfig('%s') ]]
				vim.cmd(user_cmd:format(plugin, plugin))
			end
		end
	end,
}

-- Meta-tables are awesome
return setmetatable(Plug, meta)

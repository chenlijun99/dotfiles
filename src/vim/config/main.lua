-- Fetch lazy.nvim (Lua plugin manager) if not available
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup the LazyFile event
local lazy = require("clj.lazy")
lazy.lazy_file()

-- Load all the Lua plugins in lua/clj/plugin/
require("lazy").setup("clj.plugin", {
	-- Disable annoying change detection
	change_detection = { enabled = false },
	performance = {
		rtp = {
			-- [[
			-- It is important to not reset the rtp, since we want also
			-- vim-plug to work.
			-- ]]
			reset = false,
		},
	},
})

-- Load my own Lua modules
require("clj.colorscheme")

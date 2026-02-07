Plug 'airblade/vim-rooter'
let g:rooter_silent_chdir = 0
let g:rooter_cd_cmd="lcd"
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_resolve_links = 1
let g:rooter_manual_only = 1

" '!^packages': Don't use monorepo single package as root
" '.git': Treat submodule root as project root
let g:rooter_patterns = [
			\ '!^packages',
			\ '.git/',
			\ '.git',
			\ 'package.json',
			\ 'composer.json',
			\ '.lvimrc',
			\ '.obsidian',
			\ '.Cargo.toml',
			\ '.luarc'
			\ ]

if clj#core#enable_full_power()
lua << EOF
local function load_nvim_lua_files()
	-- Collect all .nvim.lua files from current directory up to root
	local nvim_lua_files = {}
	local current_dir = vim.fn.getcwd()
	local root_dir = vim.loop.os_homedir() -- Stop at home directory

	while current_dir and current_dir ~= "/" do
		local nvim_lua_path = current_dir .. "/.nvim.lua"
		if vim.fn.filereadable(nvim_lua_path) == 1 then
			table.insert(nvim_lua_files, 1, nvim_lua_path) -- Insert at beginning for bottom-up order
		end

		-- Stop if we reached home directory
		if current_dir == root_dir then
			break
		end

		-- Move to parent directory
		local parent = vim.fn.fnamemodify(current_dir, ":h")
		if parent == current_dir then
			break -- Reached root
		end
		current_dir = parent
	end

	-- Load all found .nvim.lua files from top to bottom
	if #nvim_lua_files > 0 then
		vim.cmd([[doautocmd User CljLoadExrcPre]])

		for _, nvim_lua_path in ipairs(nvim_lua_files) do
			local str = vim.secure.read(nvim_lua_path)
			if str then
				local fn = loadstring(str)
				if fn then
					vim.notify("[Clj] Loading " .. nvim_lua_path)
					fn()
				end
			end
		end

		vim.cmd([[doautocmd User CljLoadExrcPost]])
	end
end

-- Automatically find project root once at startup. Re-rooting happens
-- manually.
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup(
		"clj-vim-rooter-startup",
		{ clear = true }
	),
	callback = function()
		vim.cmd("Rooter")
		load_nvim_lua_files()
	end,
})
-- Run .nvim.lua if vim-rooter changes CWD to a new project directory
-- Neovim only searches in CWD at startup!
--
-- Useful for e.g. I open neovim from a deep folder of a project.
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("clj-vim-rooter", { clear = true }),
	pattern = "RooterChDir",
	callback = function()
		vim.notify(
			"[Clj] Project root changed. Checking .nvim.lua in ancestor directories"
		)
		load_nvim_lua_files()
	end,
})
EOF
endif

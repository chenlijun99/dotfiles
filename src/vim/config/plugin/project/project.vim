Plug 'airblade/vim-rooter'
let g:rooter_silent_chdir = 1
let g:rooter_cd_cmd="lcd"
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_resolve_links = 1

" '!^packages': Don't use monorepo single package as root
" '.git': Treat submodule root as project root
let g:rooter_patterns = [
			\ '!^packages',
			\ '.git/',
			\ '.git',
			\ 'package.json',
			\ 'composer.json',
			\ '.lvimrc',
			\ '.obsidian'
			\ ]

if clj#core#enable_full_power()
	" Run .nvim.lua if vim-rooter changes CWD to a new project directory
	" Neovim only searches in CWD at startup!
	"
	" Useful for e.g. I open neovim from a deep folder of a project.
lua << EOF
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("clj-vim-rooter", { clear = true }),
	pattern = "RooterChDir",
	callback = function()
		vim.print(
			"Project root changed. Reading .nvim.lua if exists and is trusted"
		)
		if vim.fn.filereadable(".nvim.lua") == 1 then
			local str = vim.secure.read(".nvim.lua")
			if str then
				local fn = loadstring(str)
				if fn then
					fn()
				end
			end
		end
	end,
})
EOF
endif

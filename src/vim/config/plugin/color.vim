if clj#core#enable_full_power()
	" When using NeoVim and tree-sitter, this new gruvbox colorscheme plugin
	" (implemented Lua) supports the new highlight groups.
	Plug 'ellisonleao/gruvbox.nvim'
else
	Plug 'morhetz/gruvbox'
	let g:gruvbox_guisp_fallback = "fg"
	let g:gruvbox_undercurl = 1
endif

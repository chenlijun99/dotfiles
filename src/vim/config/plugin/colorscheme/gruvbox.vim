if clj#core#enable_full_power()
	" Vim-based old gruvbox is used only as fallback
	"
	" When using NeoVim and tree-sitter, the new gruvbox colorscheme plugin
	" (implemented Lua) supports the new tree-sitter highlight groups.
	finish
endif

Plug 'morhetz/gruvbox'
let g:gruvbox_guisp_fallback = "fg"
let g:gruvbox_undercurl = 1

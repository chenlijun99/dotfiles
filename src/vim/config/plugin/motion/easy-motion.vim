if clj#core#enable_full_power()
	" easymotion is used only as fallback
	" It's not good for full power mode because it messes up with linters,
	" LSP, etc., due to how it shows the jump markers.
	finish
endif

Plug 'easymotion/vim-easymotion'

let g:which_key_map.j = 'Jump'
map  f <Plug>(easymotion-bd-f)
nmap f <Plug>(easymotion-overwin-f)

if clj#core#enable_full_power()
	" nerdtree is used only as fallback
	finish
endif
Plug 'preservim/nerdtree', { 'on': ['NERDTreeFind', 'NERDTreeVCS', 'NERDTreeClose'] }
let g:NERDTreeWinSize=30
let g:which_key_map.p.f = 'filetree explorer'
nnoremap <silent> <leader>pf :NERDTreeFind<cr>

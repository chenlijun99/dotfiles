"tpope/vim-fugitive {{{
Plug 'tpope/vim-fugitive' , { 'on' : [] }
augroup load_fugitive
	autocmd!
	autocmd BufEnter * call plug#load('vim-fugitive')
				\ | autocmd! load_fugitive
augroup END
autocmd! User vim-fugitive call fugitive#detect(expand('%:p')) 

nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>ge :Gedit<cr>
"}}}


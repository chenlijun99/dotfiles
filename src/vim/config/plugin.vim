call plug#begin('~/.vim/bundle')

Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!', 'WhichKeyVisual'] }

let g:mapleader = "\<Space>"
let g:maplocalleader = ','
let g:which_key_map =  {}
let g:which_key_map_local =  {}
let g:which_key_map_g =  {}
let g:which_key_use_floating_win = 0
let g:which_key_map.m = { 'name': '+misc' }
autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map') |
			\ call which_key#register(',', 'g:which_key_map_local') |
			\ call which_key#register('g', 'g:which_key_map_g')

nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> g             :<c-u>WhichKey 'g'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
vnoremap <silent> <leader>      :<c-u>WhichKeyVisual '<Space>'<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual  ','<CR>

for f in globpath(expand('<sfile>:p:h'), 'plugin/**/*.vim', 0, 1)
    exe 'source' f
endfor

call plug#end()

" set modeline 
" vim: foldlevel=0 foldmethod=marker

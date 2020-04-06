let g:which_key_map.g = { 'name' : '+git' }

"tpope/vim-fugitive {{{
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

let g:which_key_map.g.s = 'Git status'
nnoremap <leader>gs :G<cr>
nnoremap <leader>gb :GBrowse<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gC :Gcommit --amend<cr>
"}}}

" junegunn/gv.vim {{{
Plug 'junegunn/gv.vim' , { 'on': ['GV', 'GV!'] }
let g:which_key_map.g.V = 'project history'
nnoremap <leader>gV :GV<cr>
let g:which_key_map.g.v =' file history' 
nnoremap <leader>gv :GV!<cr>
" }}}

" samoshkin/vim-mergetool {{{
Plug 'samoshkin/vim-mergetool' , { 'on': ['MergetoolStart'] }
let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'
" }}}

" airblade/vim-gitgutter {{{
Plug 'airblade/vim-gitgutter'
let g:gitgutter_map_keys = 0
" }}}

" idanarye/vim-merginal {{{
Plug 'idanarye/vim-merginal'
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

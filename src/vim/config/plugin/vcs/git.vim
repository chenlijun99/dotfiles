let g:which_key_map.g = { 'name' : '+git' }

"tpope/vim-fugitive {{{
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'shumphrey/fugitive-gitlab.vim'
let g:fugitive_gitlab_domains = ['http://gitlab.currymix']

let g:which_key_map.g.s = 'Git status'
nnoremap <leader>gs :G<cr>
nnoremap <leader>gb :GBrowse<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gC :Git commit --amend<cr>
"}}}

" junegunn/gv.vim {{{
Plug 'junegunn/gv.vim' , { 'on': ['GV', 'GV!'] }
let g:which_key_map.g.V = 'project history'
nnoremap <leader>gV :GV<cr>
let g:which_key_map.g.v =' file history' 
nnoremap <leader>gv :GV!<cr>
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

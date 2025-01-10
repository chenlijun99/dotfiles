let g:which_key_map.g = { 'group_name' : '+git' }

"tpope/vim-fugitive {{{
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'shumphrey/fugitive-gitlab.vim'
let g:fugitive_gitlab_domains = ['http://gitlab.currymix']

let g:which_key_map.g.s = 'Git status'
nnoremap <leader>gs :G<cr>
nnoremap <leader>gB :Git blame<cr>
nnoremap <leader>gb :GBrowse<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gC :Git commit --amend<cr>
"}}}

" rbong/vim-flog {{{
Plug 'rbong/vim-flog' ,{ 'on': ['Flog', 'Flogsplit', 'Floggit'] }
let g:flog_default_opts = {
            \ 'default_collapsed': 1,
            \ 'date': 'short',
            \ }
let g:which_key_map.g.V = 'project history'
nnoremap <leader>gV :Flog<cr>
let g:which_key_map.g.v =' file history' 
nnoremap <leader>gv :Flog -all -path=%<cr>
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

Plug 'mzlogin/vim-markdown-toc' , { 'for' : 'markdown'}

Plug 'dhruvasagar/vim-table-mode' , { 'for' : 'markdown' }
let g:table_mode_corner='|'

" iamcco/markdown-preview.nvim {{{
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
let g:mkdp_port = '28080'
let g:mkdp_auto_close = 0
" }}}
" set modeline
" vim: foldlevel=0 foldmethod=marker

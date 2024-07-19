Plug 'mzlogin/vim-markdown-toc' , { 'for' : 'markdown'}

Plug 'dhruvasagar/vim-table-mode' , { 'for' : 'markdown' , 'on': ['TableModeToggle']}
let g:table_mode_corner='|'
let g:table_mode_disable_mappings=1
let g:table_mode_disable_tableize_mappings=1
autocmd FileType markdown
			\ nnoremap <silent> <buffer> <localleader>t :TableModeToggle<CR>

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': ['markdown', 'vim-plug']}
let g:mkdp_port = '28080'
let g:mkdp_auto_close = 0
autocmd FileType markdown nnoremap <buffer> <localleader>p :MarkdownPreview<CR>

" set modeline
" vim: foldlevel=0 foldmethod=marker

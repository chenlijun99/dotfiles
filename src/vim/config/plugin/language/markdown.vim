Plug 'mzlogin/vim-markdown-toc' , { 'for' : 'markdown'}

Plug 'dhruvasagar/vim-table-mode' , { 'for' : 'markdown' , 'on': ['TableModeToggle']}
let g:table_mode_corner='|'
let g:table_mode_disable_mappings=1
let g:table_mode_disable_tableize_mappings=1
autocmd FileType markdown
			\ nnoremap <silent> <buffer> <localleader>t :TableModeToggle<CR>

" This plugin is also a good plantuml previewer
" weirongxu/plantuml-previewer.vim requires java and 'tyru/open-browser.vim' 
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': ['markdown', 'plantuml', 'vim-plug']}
let g:mkdp_port = '28080'
let g:mkdp_auto_close = 0
let g:mkdp_filetypes = ['markdown', 'plantuml']
autocmd FileType markdown,plantuml nnoremap <buffer> <localleader>p :MarkdownPreview<CR>

" set modeline
" vim: foldlevel=0 foldmethod=marker

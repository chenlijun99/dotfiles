Plug 'mzlogin/vim-markdown-toc' , { 'for' : 'markdown'}

Plug 'dhruvasagar/vim-table-mode' , { 'for' : 'markdown' }
let g:table_mode_corner='|'

Plug 'iamcco/markdown-preview.nvim', { 
			\ 'do': { -> mkdp#util#install() },
			\ 'for': 'markdown'
			\}

let g:mkdp_auto_close = 0
let g:which_key_map_local.p = 'Preview'
nnoremap <localleader>p :MarkdownPreview<CR>

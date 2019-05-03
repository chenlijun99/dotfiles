Plug 'mzlogin/vim-markdown-toc' , { 'for' : 'markdown'}

Plug 'dhruvasagar/vim-table-mode' , { 'for' : 'markdown' }
let g:table_mode_corner='|'

Plug 'iamcco/markdown-preview.nvim', { 
			\ 'do': { -> mkdp#util#install() },
			\ 'for': 'markdown'
			\}

let g:mkdp_port = '28080'
let g:mkdp_auto_close = 0

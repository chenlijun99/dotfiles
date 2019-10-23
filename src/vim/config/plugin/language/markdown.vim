Plug 'mzlogin/vim-markdown-toc' , { 'for' : 'markdown'}

Plug 'dhruvasagar/vim-table-mode' , { 'for' : 'markdown' }
let g:table_mode_corner='|'

Plug 'plasticboy/vim-markdown', { 'for' : 'markdown' } 
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_conceal = 1
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_fenced_languages = [
			\ 'asm',
			\ 'coffee',
			\ 'cpp',
			\ 'c',
			\ 'java',
			\ 'sh',
			\ 'cmake',
			\ 'rust',
			\ 'r',
			\ 'python',
			\ 'sh',
			\ 'css',
			\ 'erb=eruby',
			\ 'javascript',
			\ 'js=javascript',
			\ 'json=javascript',
			\ 'ruby',
			\ 'sass',
			\ 'xml',
			\ 'html'
			\ ]

" iamcco/markdown-preview.nvim {{{
" This causes plugin installation issues, as the function 
" used to install the pre-built binary is not available
" when PlugInstall is called from non-markdown filetype
"Plug 'iamcco/markdown-preview.nvim', { 
			"\ 'do': { -> mkdp#util#install() },
			"\ 'for': 'markdown'
			"\}
Plug 'iamcco/markdown-preview.nvim', { 
			\ 'do': { -> mkdp#util#install() },
			\}
let g:mkdp_port = '28080'
let g:mkdp_auto_close = 0
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

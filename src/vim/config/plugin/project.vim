" 'airblade/vim-rooter' {{{
Plug 'airblade/vim-rooter'
let g:rooter_silent_chdir = 1
let g:rooter_use_lcd = 1
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_resolve_links = 1
let g:rooter_patterns = [
			\ '.gitignore',
			\ '.git/',
			\ 'package.json',
			\ 'composer.json',
			\ ]
" }}}

" embear/vim-localvimrc {{{
Plug 'embear/vim-localvimrc'
let g:localvimrc_ask=0
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

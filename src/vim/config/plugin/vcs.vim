"
" VCS (Version Control Software) plugins
"

" mhinz/vim-signify {{{
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
let g:which_key_map_global_next.g = 'Next unstaged chunk'
let g:which_key_map_global_previous.g = 'Previous unstaged chunk'
let g:which_key_map_global_next.G = 'Last unstaged chunk'
let g:which_key_map_global_previous.G = 'First unstaged chunk'
nmap ]g <plug>(signify-next-hunk)
nmap [g <plug>(signify-prev-hunk)
nmap ]G 9999<leader>]g
nmap [G 9999<leader>[g
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

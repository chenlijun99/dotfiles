setlocal spell spelllang=en,it,cjk
setlocal lazyredraw
setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
setlocal conceallevel=2
setlocal textwidth=80
setlocal formatoptions-=t

let g:which_key_map_local.p = 'Preview'
nnoremap <buffer> <localleader>p :MarkdownPreview<CR>

let g:which_key_map_local.t = 'Table of Contents'
nnoremap <buffer> <localleader>t :Vista toc<CR>
let g:which_key_map_local.T = 'Close Table of Contents'
nnoremap <buffer> <localleader>T :Vista!<CR>

" set modeline 
" vim: foldlevel=0 foldmethod=marker

setlocal spell spelllang=en,it,cjk
setlocal lazyredraw
setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
setlocal conceallevel=2

let g:which_key_map_local.p = 'Preview'
nnoremap <buffer> <localleader>p :MarkdownPreview<CR>

" set modeline 
" vim: foldlevel=0 foldmethod=marker

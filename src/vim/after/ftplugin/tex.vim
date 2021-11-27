setlocal spell spelllang=en,it,cjk
setlocal wrap

let g:which_key_map_local.p = 'Preview'
nmap <buffer> <localleader>p <Plug>(vimtex-compile)
let g:which_key_map_local.p = 'Preview'
xmap <buffer> <localleader>p <Plug>(vimtex-compile-selected)
let g:which_key_map_local.t = 'Table of Contents'
nmap <buffer> <localleader>t <Plug>(vimtex-toc-open)
let g:which_key_map_local.t = 'Toggle focus'
nnoremap <buffer> <localleader>g :Goyo<cr>

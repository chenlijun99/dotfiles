setlocal spell spelllang=en,it,cjk

let g:which_key_map_local.p = 'Preview'
nmap <buffer> <localleader>p <Plug>(vimtex-compile)
let g:which_key_map_local.p = 'Preview'
xmap <buffer> <localleader>p <Plug>(vimtex-compile-selected)
let g:which_key_map_local.t = 'Table of Contents'
nmap <buffer> <localleader>t <Plug>(vimtex-toc-open)

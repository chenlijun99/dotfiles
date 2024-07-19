Plug 'lervag/vimtex', { 'for' : ['tex', 'latex', 'plaintex']}
let g:vimtex_view_general_viewer = 'zathura'
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-pdf',
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}
" Disable this option since it's too slow
" https://github.com/lervag/vimtex/issues/513
let g:vimtex_matchparen_enabled = 0
autocmd FileType tex,latex,plaintex
			\ nnoremap <buffer> <localleader>p <Plug>(vimtex-compile)
			\ | xnoremap <buffer> <localleader>p <Plug>(vimtex-compile-selected)
			\ | nnoremap <buffer> <localleader>t <Plug>(vimtex-toc-open)

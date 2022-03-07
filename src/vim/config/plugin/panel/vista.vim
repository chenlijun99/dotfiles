let g:which_key_map.p.s = 'symbol explorer'
Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
nnoremap <silent> <leader>ps :Vista<cr>
let g:vista_default_executive = 'ctags'
let g:vista_executive_for = {
			\ 'c': 'coc',
			\ 'cpp': 'coc',
			\ 'typescript': 'coc',
			\ 'markdown': 'toc',
			\ }
let g:which_key_map.p.S = { 'name' : '+symbol tree' }
let g:which_key_map.p.S.x = "Close"
nnoremap <silent> <leader>pSx :Vista!<cr>

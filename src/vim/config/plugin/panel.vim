let g:which_key_map.p = { 'name' : '+panel' }

" defx {{{

Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'kristijanhusak/defx-icons', { 'do': ':UpdateRemotePlugins' }
Plug 'kristijanhusak/defx-git', { 'do': ':UpdateRemotePlugins' }

let g:which_key_map.p.f = 'filetree explorer'
nnoremap <silent> <leader>pf :Defx `getcwd()` -search=`expand('%:p')`<cr>
" }}}

" liuchengxu/vista.vim {{{
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
" }}}

" Valloric/ListToggle {{{
"Plug 'Valloric/ListToggle'
"" set location list height
"let g:lt_height=10
"let g:which_key_map.p.l = 'toggle loclist'
"let g:lt_location_list_toggle_map = '<leader>pl'
"let g:which_key_map.p.q = 'toggle quickfix'
"let g:lt_quickfix_list_toggle_map = '<leader>pq'

"nmap <Plug>JumpNextLocationList :lnext<Bar>
			"\ silent! call repeat#set("\<Plug>JumpNextLocationList")<cr>
"nmap <c-j> <Plug>JumpNextLocationList
"nmap <Plug>JumpPreviousLocationList :lprevious<Bar>
			"\ silent! call repeat#set("\<Plug>JumpPreviousLocationList")<cr>
"nmap <c-k> <Plug>JumpPreviousLocationList

"nmap <Plug>JumpNextQuickFix :cnext<Bar>
			"\ silent! call repeat#set("\<Plug>JumpNextQuickFix")<cr>
"nmap <leader>j <Plug>JumpNextQuickFix
"nmap <Plug>JumpPreviousQuickFix :cprevious<Bar>
			"\ silent! call repeat#set("\<Plug>JumpPreviousQuickFix")<cr>
"nmap <leader>k <Plug>JumpPreviousQuickFix
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker

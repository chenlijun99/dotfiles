let g:which_key_map.p = { 'name' : '+panel' }

" scrooloose/nerdtree {{{
Plug 'scrooloose/nerdtree'
let g:NERDTreeWinSize=30
let g:which_key_map.p.f = 'filetree explorer'
nnoremap <silent> <leader>pf :NERDTreeFind<cr>
" }}}
" xuyuanp/nerdtree-git-plugin {{{
Plug 'xuyuanp/nerdtree-git-plugin'
" }}}

" liuchengxu/vista.vim {{{
let g:which_key_map.p.s = 'symbol explorer'
let g:vista_default_executive = 'coc'
Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
nnoremap <silent> <leader>ps :Vista<cr>

" }}}

" {{{
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

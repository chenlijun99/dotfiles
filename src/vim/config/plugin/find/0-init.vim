let g:which_key_map.f = { 'group_name' : '+find' }
let g:which_key_map.f.r = { 'group_name' : '+replace' }

" dyng/ctrlsf.vim {{{
let g:which_key_map.f.r.c = {
			\ 'map_name': '(CtrlSF)',
			\ 'mode': ['n', 'x'],
			\}
nnoremap <leader>frc :CtrlSF<Space>
xnoremap <leader>frc :<C-u>call <SID>VSetSearch()<CR>:CtrlSF<Space><C-R>=@/<CR><CR>

Plug 'dyng/ctrlsf.vim',
			\ { 'on': ['CtrlSF'] }

" }}}

" tpope/vim-abolish {{{
Plug 'tpope/vim-abolish',
			\ { 'on': ['Abolish', 'Subvert'] }

let g:which_key_map.f.r.c = {
			\ 'map_name': 'Subvert',
			\ 'mode': ['x'],
			\}
xnoremap <leader>frs :<C-u>call <SID>VSetSearch()<CR>:%Subvert/<C-R>=@/<CR>//gc<left><left><left>
" }}}

let g:which_key_map.f.r.c = {
			\ 'map_name': 'built-n',
			\ 'mode': ['x'],
			\}
" from SpaceVim
xnoremap <leader>frr :<C-u>call <SID>VSetSearch()<CR>:%s/<C-R>=@/<CR>//gc<left><left><left>
function! s:VSetSearch() abort
	let temp = @s
	norm! gv"sy
	" Escape expression '\\/.*$^~[]' is from https://superuser.com/a/320514
	let @/ = substitute(escape(@s, '\\/.*$^~[]'), '\n', '\\n', 'g')
	let @s = temp
endfunction

" set modeline
" vim: foldlevel=0 foldmethod=marker

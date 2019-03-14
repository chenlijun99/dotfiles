let g:which_key_map["'"] = 'Terminal project'
let g:which_key_map["\""] = 'Terminal current path'

nnoremap <silent><leader>' :call FreeEasy#shell#open_default_shell(0)<CR>
nnoremap <silent><leader>" :call FreeEasy#shell#open_default_shell(1)<CR>

if has('nvim') || exists(':tnoremap') == 2
	tnoremap <silent><C-Right> <C-\><C-n>:<C-u>wincmd l<CR>
	tnoremap <silent><C-Left>  <C-\><C-n>:<C-u>wincmd h<CR>
	tnoremap <silent><C-Up>    <C-\><C-n>:<C-u>wincmd k<CR>
	tnoremap <silent><C-Down>  <C-\><C-n>:<C-u>wincmd j<CR>
	tnoremap <silent><M-Left>  <C-\><C-n>:<C-u>bprev<CR>
	tnoremap <silent><M-Right>  <C-\><C-n>:<C-u>bnext<CR>
	tnoremap <silent><esc>     <C-\><C-n>
	if has('win32')
		tnoremap <expr><silent><C-d> :FreeEasy#shell#terminal()
		tnoremap <expr><silent><C-u> :FreeEasy#shell#ctrl_u()
		tnoremap <expr><silent><C-w> :FreeEasy#shell#ctrl_w()
		tnoremap <expr><silent><C-r> :FreeEasy#shell#ctrl_r()
	endif
endif
" in window gvim, use <C-d> to close terminal buffer

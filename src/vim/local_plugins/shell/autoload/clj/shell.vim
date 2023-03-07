"=============================================================================
" shell.vim --- SpaceVim shell layer
" Copyright (c) 2016-2017 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg at 163.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

let s:file = expand('<sfile>:~')
let s:lnum = expand('<slnum>') + 2

let s:default_position = 'bottom'
let s:default_height = 30
let s:shell_cached_br = {}

func! clj#shell#terminal() abort
	let line = getline('$')
	if isdirectory(line[:-2])
		return "exit\<CR>"
	endif
	return "\<C-d>"
endf
func! clj#shell#ctrl_u() abort
	let line = getline('$')
	let prompt = getcwd() . '>'
	return repeat("\<BS>", len(line) - len(prompt) + 2)
endfunction

func! clj#shell#ctrl_r() abort
	let reg = getchar()
	if reg == 43
		return @+
	endif
endfunction

func! clj#shell#ctrl_w() abort
	let cursorpos = term_getcursor(s:term_buf_nr)
	let line = getline(cursorpos[0])[:cursorpos[1]-1]
	let str = matchstr(line, '[^ ]*\s*$')
	return repeat("\<BS>", len(str))
endfunction

let s:open_terminals_buffers = []
" shell windows shoud be toggleable, and can be hide.
function! clj#shell#open_default_shell(open_with_file_cwd) abort
	if a:open_with_file_cwd
		if getwinvar(winnr(), '&buftype') ==# 'terminal'
			let path = getbufvar(winbufnr(winnr()), '_spacevim_shell_cwd', getcwd())
		else
			let path = expand('%:p:h')
		endif
	else
		let path = getcwd() 
	endif

	" look for already opened terminal windows
	let windows = [] 
	windo call add(windows, winnr()) 
	for window in windows
		if getwinvar(window, '&buftype') ==# 'terminal'
			exe window .  'wincmd w'
			if getbufvar(winbufnr(window), '_spacevim_shell_cwd') ==# l:path
				" fuck gvim bug, startinsert do not work in gvim
				if has('nvim')
					startinsert
				else
					normal! a
				endif
				return
			else
				" the opened terminal window is not the one we want.
				" close it, we're gonna open a new terminal window with the given l:path
				exe 'wincmd c'
				break
			endif
		endif
	endfor

	" no terminal window found. Open a new window
	let cmd = s:default_position ==# 'top' ?
				\ 'topleft split' :
				\ s:default_position ==# 'bottom' ?
				\ 'botright split' :
				\ s:default_position ==# 'right' ?
				\ 'rightbelow vsplit' : 'leftabove vsplit'
	exe cmd
	let w:shell_layer_win = 1
	let lines = &lines * s:default_height / 100
	if lines < winheight(0) && (s:default_position ==# 'top' || s:default_position ==# 'bottom')
		exe 'resize ' . lines
	endif
	for open_terminal in s:open_terminals_buffers
		if bufexists(open_terminal)
			if getbufvar(open_terminal, "_spacevim_shell_cwd") ==# l:path
				exe 'silent b' . open_terminal
				" clear the message 
				if has('nvim')
					startinsert
				else
					normal! a
				endif
				return
			endif
		else
			" remove closed buffer from list
			call remove(s:open_terminals_buffers, 0)
		endif
	endfor

	" no terminal window with l:path as cwd has been found, let's open one
	if exists(':terminal')
		if has('nvim')
			if has('win32')
				let shell = empty($SHELL) ? 'cmd.exe' : $SHELL
			else
				let shell = empty($SHELL) ? 'bash' : $SHELL
			endif
			enew
			call termopen(shell, {'cwd': l:path})
			" @bug cursor is not cleared when open terminal windows.
			" in neovim-qt when using :terminal to open a shell windows, the orgin
			" cursor position will be highlighted. switch to normal mode and back
			" is to clear the highlight.
			" This seem a bug of neovim-qt in windows.
			"
			" cc @equalsraf
			if has('win32') && has('nvim')
				stopinsert
				startinsert
			endif
			let l:term_buf_nr = bufnr('%')
			call extend(s:shell_cached_br, {getcwd() : l:term_buf_nr})
		else 
			" handle vim terminal
			if has('win32')
				let shell = empty($SHELL) ? 'cmd.exe' : $SHELL
			else
				let shell = empty($SHELL) ? 'bash' : $SHELL
			endif
			let l:term_buf_nr = term_start(shell, {'cwd': l:path, 'curwin' : 1, 'term_finish' : 'close'})
		endif
		call add(s:open_terminals_buffers, l:term_buf_nr)
		let b:_spacevim_shell = shell
		let b:_spacevim_shell_cwd = l:path

		" use WinEnter autocmd to update statusline
		doautocmd WinEnter
		setlocal nobuflisted nonumber norelativenumber

		startinsert
	else
		echo ':terminal is not supported in this version'
	endif
endfunction

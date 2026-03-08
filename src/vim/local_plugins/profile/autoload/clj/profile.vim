" Profile detection functions.
" Called during plug#begin (the rtp is prepended in main.vim before plug#begin
" so this autoload is available at that point).

" Return the active profile name.
" Priority: $VIM_CLJ_PROFILE env var > stdpath('state')/profile file > 'minimal'
func! clj#profile#get()
	let l:profile = $VIM_CLJ_PROFILE
	if !empty(l:profile)
		return trim(l:profile)
	endif

	if has('nvim')
		let l:state_file = stdpath('state') . '/profile'
	else
		let l:state_file = expand('~/.local/state/nvim/profile')
	endif

	if filereadable(l:state_file)
		let l:lines = readfile(l:state_file, '', 1)
		if len(l:lines) > 0
			return trim(l:lines[0])
		endif
	endif

	return 'minimal'
endf

func! clj#profile#is_full()
	return clj#profile#get() ==# 'full'
endf

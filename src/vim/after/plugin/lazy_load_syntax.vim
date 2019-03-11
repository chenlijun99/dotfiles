syntax off
augroup load_syntax
	autocmd!
	autocmd cursorhold * syntax on | call lightline#enable()
				\| hi CurrentWord ctermbg=239 cterm=bold 
				\| hi CurrentWordTwins ctermbg=239
				\| autocmd! load_syntax
augroup end

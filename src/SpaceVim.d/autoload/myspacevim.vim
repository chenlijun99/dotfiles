func! myspacevim#before() abort
	let g:NERDTreeWinPos = "left"
	let g:spacevim_autocomplete_method = 'coc'
endf
func! myspacevim#after() abort
	RainbowParentheses
endf

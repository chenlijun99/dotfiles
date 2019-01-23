inoremap <silent><expr> <c-space> coc#refresh()

call coc#config('coc.preferences', {
			\ "autoTrigger": "always",
			\ "maxCompleteItemCount": 10,
			\})

hi CocHighlightText ctermbg=239 cterm=bold 
autocmd CursorHold * silent call CocActionAsync('highlight')

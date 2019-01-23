inoremap <silent><expr> <c-space> coc#refresh()

call coc#config('coc.preferences', {
			\ "autoTrigger": "always",
			\ "maxCompleteItemCount": 10,
			\ "codeLens.enable": 1,
			\ "diagnostic.virtualText": 1,
			\})

autocmd CursorHold * silent call CocActionAsync('highlight')
hi CocHighlightText cterm=bold ctermbg=241 gui=bold guibg=#665c54

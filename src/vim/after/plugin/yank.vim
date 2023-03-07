if exists('##TextYankPost')
	augroup highlight_yank
		autocmd!
		autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank {higroup="Search", timeout=500}
	augroup END
endif
